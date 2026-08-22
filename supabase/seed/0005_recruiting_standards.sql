-- Seed: sample NCAA recruiting cut times
-- SEED DATA ONLY — publicly published cuts change yearly.
-- Label clearly in UI as sample / illustrative.

create or replace function public._seed_recruit(
  p_tier public.ncaa_tier,
  p_gender public.gender,
  p_stroke public.stroke,
  p_distance integer,
  p_course public.course,
  p_cut_ms integer,
  p_label text,
  p_year integer default 2025
) returns void
language plpgsql
as $$
declare
  eid uuid;
begin
  select id into eid from public.events_catalog
  where stroke = p_stroke and distance_m = p_distance and course = p_course and is_relay = false;
  if eid is null then return; end if;
  insert into public.recruiting_standards (
    tier, gender, event_catalog_id, cut_time_ms, label, source, season_year
  ) values (
    p_tier, p_gender, eid, p_cut_ms, p_label,
    'seed — sample public cuts; update yearly', p_year
  )
  on conflict (tier, gender, event_catalog_id) do update
  set cut_time_ms = excluded.cut_time_ms,
      label = excluded.label,
      season_year = excluded.season_year;
end;
$$;

-- SCY Men sample cuts
select public._seed_recruit('D1_A', 'M', 'free', 50, 'SCY', 19500, 'Meets D1 A-cut: 50 Free');
select public._seed_recruit('D1_B', 'M', 'free', 50, 'SCY', 20500, 'Meets D1 B-cut: 50 Free');
select public._seed_recruit('D1_A', 'M', 'free', 100, 'SCY', 42500, 'Meets D1 A-cut: 100 Free');
select public._seed_recruit('D1_B', 'M', 'free', 100, 'SCY', 45000, 'Meets D1 B-cut: 100 Free');
select public._seed_recruit('D1_A', 'M', 'free', 200, 'SCY', 94000, 'Meets D1 A-cut: 200 Free');
select public._seed_recruit('D1_B', 'M', 'free', 200, 'SCY', 99000, 'Meets D1 B-cut: 200 Free');
select public._seed_recruit('D1_B', 'M', 'back', 100, 'SCY', 49000, 'Meets D1 B-cut: 100 Back');
select public._seed_recruit('D1_B', 'M', 'breast', 100, 'SCY', 55000, 'Meets D1 B-cut: 100 Breast');
select public._seed_recruit('D1_B', 'M', 'fly', 100, 'SCY', 48000, 'Meets D1 B-cut: 100 Fly');
select public._seed_recruit('D1_B', 'M', 'im', 200, 'SCY', 108000, 'Meets D1 B-cut: 200 IM');
select public._seed_recruit('D2', 'M', 'free', 100, 'SCY', 48000, 'Meets D2 cut: 100 Free');
select public._seed_recruit('D3', 'M', 'free', 100, 'SCY', 52000, 'Meets D3 cut: 100 Free');

-- SCY Women sample cuts
select public._seed_recruit('D1_A', 'F', 'free', 50, 'SCY', 22000, 'Meets D1 A-cut: 50 Free');
select public._seed_recruit('D1_B', 'F', 'free', 50, 'SCY', 23200, 'Meets D1 B-cut: 50 Free');
select public._seed_recruit('D1_A', 'F', 'free', 100, 'SCY', 48000, 'Meets D1 A-cut: 100 Free');
select public._seed_recruit('D1_B', 'F', 'free', 100, 'SCY', 50500, 'Meets D1 B-cut: 100 Free');
select public._seed_recruit('D1_A', 'F', 'free', 200, 'SCY', 105000, 'Meets D1 A-cut: 200 Free');
select public._seed_recruit('D1_B', 'F', 'free', 200, 'SCY', 110000, 'Meets D1 B-cut: 200 Free');
select public._seed_recruit('D1_B', 'F', 'back', 100, 'SCY', 55000, 'Meets D1 B-cut: 100 Back');
select public._seed_recruit('D1_B', 'F', 'breast', 100, 'SCY', 62000, 'Meets D1 B-cut: 100 Breast');
select public._seed_recruit('D1_B', 'F', 'fly', 100, 'SCY', 54500, 'Meets D1 B-cut: 100 Fly');
select public._seed_recruit('D1_B', 'F', 'im', 200, 'SCY', 120000, 'Meets D1 B-cut: 200 IM');
select public._seed_recruit('D2', 'F', 'free', 100, 'SCY', 54000, 'Meets D2 cut: 100 Free');
select public._seed_recruit('D3', 'F', 'free', 100, 'SCY', 58000, 'Meets D3 cut: 100 Free');

drop function public._seed_recruit(public.ncaa_tier, public.gender, public.stroke, integer, public.course, integer, text, integer);
