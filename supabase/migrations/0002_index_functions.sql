-- Index computation: World Aquatics points-table style
-- event_index = 1000 * (standard_time / swimmer_time)^3
-- DQ and unverified performances are excluded.
-- Relay legs are excluded from individual composite (prevent double-count).

create or replace function public.event_index_points(
  standard_time_ms integer,
  swimmer_time_ms integer
) returns numeric
language sql
immutable
as $$
  select case
    when standard_time_ms is null or swimmer_time_ms is null then null
    when standard_time_ms <= 0 or swimmer_time_ms <= 0 then null
    else round(
      1000.0 * power(standard_time_ms::numeric / swimmer_time_ms::numeric, 3),
      3
    )
  end;
$$;

create or replace function public.recency_weight(
  competition_date date,
  half_life_days numeric default 365
) returns numeric
language sql
immutable
as $$
  select power(
    0.5,
    greatest(0, (current_date - competition_date))::numeric / nullif(half_life_days, 0)
  );
$$;

create or replace function public.meet_level_weight(level public.meet_level)
returns numeric
language plpgsql
stable
as $$
declare
  weights jsonb;
  w numeric;
begin
  select value into weights from public.app_config where key = 'meet_level_weights';
  w := (weights ->> level::text)::numeric;
  return coalesce(w, 1.0);
end;
$$;

-- Converted equivalent time (estimated only — never overwrite recorded time)
create or replace function public.convert_course_time(
  time_ms integer,
  p_stroke public.stroke,
  p_distance integer,
  from_course public.course,
  to_course public.course
) returns integer
language plpgsql
stable
as $$
declare
  mult numeric;
begin
  if from_course = to_course then
    return time_ms;
  end if;
  select multiplier into mult
  from public.course_conversion_factors
  where stroke = p_stroke
    and distance_m = p_distance
    and course_conversion_factors.from_course = convert_course_time.from_course
    and course_conversion_factors.to_course = convert_course_time.to_course;
  if mult is null then
    return null;
  end if;
  return round(time_ms * mult)::integer;
end;
$$;

-- Score a single verified performance (open + age-adjusted)
create or replace function public.score_performance(perf_id uuid)
returns void
language plpgsql
security definer
as $$
declare
  perf public.performances%rowtype;
  open_std integer;
  ag_std integer;
  swimmer_gender public.gender;
begin
  select * into perf from public.performances where id = perf_id;
  if not found then
    return;
  end if;

  -- DQ and unverified never receive index points
  if perf.dq or perf.verification_status <> 'verified' then
    update public.performances
    set open_event_index = null,
        age_adjusted_event_index = null,
        is_personal_best = false
    where id = perf_id;
    return;
  end if;

  -- Relay legs do not feed individual index
  if perf.is_relay then
    update public.performances
    set open_event_index = null,
        age_adjusted_event_index = null
    where id = perf_id;
    -- still allow PB tracking for relay legs? Spec: don't double-count in index.
    -- Keep PB only for individual races.
  end if;

  select gender into swimmer_gender from public.profiles where id = perf.swimmer_id;

  select time_ms into open_std
  from public.standard_times
  where event_catalog_id = perf.event_catalog_id
    and gender = swimmer_gender;

  select time_ms into ag_std
  from public.age_group_standard_times
  where event_catalog_id = perf.event_catalog_id
    and gender = swimmer_gender
    and age_min <= coalesce(perf.seasonal_age_at_meet, 99)
    and age_max >= coalesce(perf.seasonal_age_at_meet, 99)
  order by standard_label
  limit 1;

  update public.performances
  set open_event_index = case
        when perf.is_relay then null
        else public.event_index_points(open_std, perf.time_ms)
      end,
      age_adjusted_event_index = case
        when perf.is_relay then null
        else public.event_index_points(ag_std, perf.time_ms)
      end
  where id = perf_id;

  -- Refresh personal best for this event (individual only, non-DQ, verified)
  if not perf.is_relay then
    perform public.refresh_personal_best(perf.swimmer_id, perf.event_catalog_id);
  end if;
end;
$$;

create or replace function public.refresh_personal_best(
  p_swimmer uuid,
  p_event uuid
) returns void
language plpgsql
security definer
as $$
declare
  best record;
begin
  -- Clear PB flags for this event
  update public.performances
  set is_personal_best = false
  where swimmer_id = p_swimmer and event_catalog_id = p_event;

  select id, time_ms, course, competition_date
  into best
  from public.performances
  where swimmer_id = p_swimmer
    and event_catalog_id = p_event
    and verification_status = 'verified'
    and dq = false
    and is_relay = false
  order by time_ms asc, competition_date desc
  limit 1;

  if best.id is null then
    delete from public.personal_bests
    where swimmer_id = p_swimmer and event_catalog_id = p_event;
    return;
  end if;

  update public.performances set is_personal_best = true where id = best.id;

  insert into public.personal_bests (
    swimmer_id, event_catalog_id, performance_id, time_ms, course, achieved_on
  ) values (
    p_swimmer, p_event, best.id, best.time_ms, best.course, best.competition_date
  )
  on conflict (swimmer_id, event_catalog_id) do update
  set performance_id = excluded.performance_id,
      time_ms = excluded.time_ms,
      course = excluded.course,
      achieved_on = excluded.achieved_on;
end;
$$;

-- Composite index: top-N best event indices, weighted by recency + meet level
create or replace function public.recompute_swimmer_index(p_swimmer uuid)
returns void
language plpgsql
security definer
as $$
declare
  top_n integer;
  half_life numeric;
  open_score numeric := 0;
  age_score numeric := 0;
  open_w numeric := 0;
  age_w numeric := 0;
  counted integer := 0;
  r record;
  w numeric;
begin
  select (value #>> '{}')::integer into top_n
  from public.app_config where key = 'index_top_n';
  select (value #>> '{}')::numeric into half_life
  from public.app_config where key = 'recency_half_life_days';
  top_n := coalesce(top_n, 5);
  half_life := coalesce(half_life, 365);

  -- Best open event_index per canonical event (course-specific row in catalog)
  for r in
    with best_per_event as (
      select distinct on (event_catalog_id)
        event_catalog_id,
        open_event_index,
        age_adjusted_event_index,
        competition_date,
        meet_level
      from public.performances
      where swimmer_id = p_swimmer
        and verification_status = 'verified'
        and dq = false
        and is_relay = false
        and open_event_index is not null
      order by event_catalog_id, open_event_index desc, competition_date desc
    )
    select *
    from best_per_event
    order by open_event_index desc
    limit top_n
  loop
    w := public.recency_weight(r.competition_date, half_life)
         * public.meet_level_weight(r.meet_level);
    open_score := open_score + coalesce(r.open_event_index, 0) * w;
    open_w := open_w + w;
    counted := counted + 1;
  end loop;

  for r in
    with best_per_event as (
      select distinct on (event_catalog_id)
        event_catalog_id,
        age_adjusted_event_index,
        competition_date,
        meet_level
      from public.performances
      where swimmer_id = p_swimmer
        and verification_status = 'verified'
        and dq = false
        and is_relay = false
        and age_adjusted_event_index is not null
      order by event_catalog_id, age_adjusted_event_index desc, competition_date desc
    )
    select *
    from best_per_event
    order by age_adjusted_event_index desc
    limit top_n
  loop
    w := public.recency_weight(r.competition_date, half_life)
         * public.meet_level_weight(r.meet_level);
    age_score := age_score + coalesce(r.age_adjusted_event_index, 0) * w;
    age_w := age_w + w;
  end loop;

  insert into public.swimmer_indices (
    swimmer_id, open_index, age_adjusted_index, events_counted, last_computed_at
  ) values (
    p_swimmer,
    case when open_w > 0 then round(open_score / open_w, 3) else null end,
    case when age_w > 0 then round(age_score / age_w, 3) else null end,
    counted,
    now()
  )
  on conflict (swimmer_id) do update
  set open_index = excluded.open_index,
      age_adjusted_index = excluded.age_adjusted_index,
      events_counted = excluded.events_counted,
      last_computed_at = excluded.last_computed_at;
end;
$$;

create or replace function public.recompute_all_indices()
returns integer
language plpgsql
security definer
as $$
declare
  n integer := 0;
  sid uuid;
begin
  for sid in select id from public.profiles where role = 'swimmer' loop
    perform public.recompute_swimmer_index(sid);
    n := n + 1;
  end loop;
  return n;
end;
$$;

-- Refresh scholarship "standards met" from verified PBs
create or replace function public.refresh_scholarship_standards(p_swimmer uuid)
returns void
language plpgsql
security definer
as $$
declare
  met jsonb := '[]'::jsonb;
  r record;
  swimmer_gender public.gender;
begin
  select gender into swimmer_gender from public.profiles where id = p_swimmer;

  for r in
    select rs.label, rs.tier, ec.label as event_label, rs.cut_time_ms, pb.time_ms
    from public.personal_bests pb
    join public.recruiting_standards rs
      on rs.event_catalog_id = pb.event_catalog_id
     and rs.gender = swimmer_gender
    join public.events_catalog ec on ec.id = pb.event_catalog_id
    where pb.swimmer_id = p_swimmer
      and pb.time_ms <= rs.cut_time_ms
  loop
    met := met || jsonb_build_array(jsonb_build_object(
      'label', r.label,
      'tier', r.tier,
      'event', r.event_label,
      'cut_time_ms', r.cut_time_ms,
      'pb_time_ms', r.time_ms
    ));
  end loop;

  insert into public.scholarship_profiles (swimmer_id, standards_met, updated_at)
  values (p_swimmer, met, now())
  on conflict (swimmer_id) do update
  set standards_met = excluded.standards_met,
      updated_at = now();
end;
$$;

-- Triggered after verification status changes
create or replace function public.on_performance_verified()
returns trigger
language plpgsql
security definer
as $$
begin
  if new.verification_status = 'verified'
     and (tg_op = 'INSERT' or old.verification_status is distinct from new.verification_status
          or old.dq is distinct from new.dq or old.time_ms is distinct from new.time_ms)
  then
    if new.seasonal_age_at_meet is null then
      new.seasonal_age_at_meet := (
        select public.compute_seasonal_age(p.date_of_birth, new.competition_date)
        from public.profiles p where p.id = new.swimmer_id
      );
    end if;
  end if;
  return new;
end;
$$;

create trigger performances_before_verify
  before insert or update on public.performances
  for each row execute function public.on_performance_verified();

create or replace function public.after_performance_change()
returns trigger
language plpgsql
security definer
as $$
begin
  perform public.score_performance(new.id);
  perform public.recompute_swimmer_index(new.swimmer_id);
  perform public.refresh_scholarship_standards(new.swimmer_id);
  return new;
end;
$$;

create trigger performances_after_change
  after insert or update of verification_status, dq, time_ms, event_catalog_id
  on public.performances
  for each row execute function public.after_performance_change();

-- Season boundary aging-up: recompute seasonal age for all swimmers
create or replace function public.recompute_seasonal_ages(
  reference_date date default current_date
) returns integer
language plpgsql
security definer
as $$
declare
  n integer := 0;
  boundary_month integer := 9;
  boundary_day integer := 1;
  cfg jsonb;
begin
  select value into cfg from public.app_config where key = 'season_boundary';
  if cfg is not null then
    boundary_month := coalesce((cfg ->> 'month')::integer, 9);
    boundary_day := coalesce((cfg ->> 'day')::integer, 1);
  end if;

  update public.profiles
  set seasonal_age = public.compute_seasonal_age(
        date_of_birth, reference_date, boundary_month, boundary_day
      ),
      age_group_label = public.age_group_label(
        public.compute_seasonal_age(
          date_of_birth, reference_date, boundary_month, boundary_day
        )
      ),
      updated_at = now()
  where date_of_birth is not null
    and role = 'swimmer';

  get diagnostics n = row_count;

  -- Re-score age-adjusted indices after age-group rebucket
  perform public.recompute_all_indices();
  return n;
end;
$$;
