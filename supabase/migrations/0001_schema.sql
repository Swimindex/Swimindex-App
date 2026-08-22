-- SwimIndex v2 schema — swimming-specific domain model
-- Roles: swimmer | coach | admin

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
create type public.user_role as enum ('swimmer', 'coach', 'admin');
create type public.stroke as enum ('free', 'back', 'breast', 'fly', 'im');
create type public.course as enum ('SCY', 'SCM', 'LCM');
create type public.gender as enum ('M', 'F', 'X');
create type public.meet_level as enum (
  'dual',
  'invitational',
  'sectional',
  'state',
  'national',
  'international',
  'olympic_trials'
);
create type public.race_round as enum ('prelim', 'final', 'timed_final');
create type public.dq_reason as enum (
  'false_start',
  'stroke_infraction',
  'illegal_turn',
  'illegal_finish',
  'other'
);
create type public.verification_status as enum (
  'pending',
  'verified',
  'rejected'
);
create type public.ncaa_tier as enum (
  'D1_A',
  'D1_B',
  'D2',
  'D3',
  'NAIA',
  'JUCO'
);

-- ---------------------------------------------------------------------------
-- Canonical event catalog (legal stroke/distance/course combos only)
-- ---------------------------------------------------------------------------
create table public.events_catalog (
  id uuid primary key default gen_random_uuid(),
  stroke public.stroke not null,
  distance_m integer not null check (distance_m > 0),
  course public.course not null,
  is_relay boolean not null default false,
  label text not null,
  created_at timestamptz not null default now(),
  unique (stroke, distance_m, course, is_relay)
);

create index events_catalog_lookup_idx
  on public.events_catalog (course, stroke, distance_m);

-- ---------------------------------------------------------------------------
-- Open / elite standard times (World Aquatics–style reference)
-- ---------------------------------------------------------------------------
create table public.standard_times (
  id uuid primary key default gen_random_uuid(),
  event_catalog_id uuid not null references public.events_catalog (id) on delete cascade,
  gender public.gender not null,
  time_ms integer not null check (time_ms > 0),
  source text not null default 'seed',
  effective_from date,
  notes text,
  unique (event_catalog_id, gender)
);

-- ---------------------------------------------------------------------------
-- Age-group motivational / AG standards
-- ---------------------------------------------------------------------------
create table public.age_group_standard_times (
  id uuid primary key default gen_random_uuid(),
  event_catalog_id uuid not null references public.events_catalog (id) on delete cascade,
  gender public.gender not null,
  age_min integer not null check (age_min >= 0),
  age_max integer not null check (age_max >= age_min),
  time_ms integer not null check (time_ms > 0),
  standard_label text not null default 'AAAA',
  source text not null default 'seed',
  unique (event_catalog_id, gender, age_min, age_max, standard_label)
);

-- ---------------------------------------------------------------------------
-- Course conversion factors (USA Swimming–style). Never overwrite recorded times.
-- ---------------------------------------------------------------------------
create table public.course_conversion_factors (
  id uuid primary key default gen_random_uuid(),
  stroke public.stroke not null,
  distance_m integer not null,
  from_course public.course not null,
  to_course public.course not null,
  multiplier numeric(10, 6) not null check (multiplier > 0),
  source text not null default 'seed',
  notes text,
  check (from_course <> to_course),
  unique (stroke, distance_m, from_course, to_course)
);

-- ---------------------------------------------------------------------------
-- Profiles
-- ---------------------------------------------------------------------------
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text not null unique,
  display_name text not null,
  role public.user_role not null default 'swimmer',
  gender public.gender,
  date_of_birth date,
  region text,
  club_name text,
  seasonal_age integer,
  age_group_label text,
  bio text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index profiles_username_idx on public.profiles (username);
create index profiles_role_idx on public.profiles (role);

-- ---------------------------------------------------------------------------
-- Coach ↔ swimmer relationships
-- ---------------------------------------------------------------------------
create table public.coach_swimmers (
  coach_id uuid not null references public.profiles (id) on delete cascade,
  swimmer_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (coach_id, swimmer_id)
);

-- ---------------------------------------------------------------------------
-- Competitions / meets
-- ---------------------------------------------------------------------------
create table public.competitions (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  meet_level public.meet_level not null default 'invitational',
  course public.course not null,
  start_date date not null,
  end_date date,
  location text,
  region text,
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Races (event instances within a meet)
-- ---------------------------------------------------------------------------
create table public.races (
  id uuid primary key default gen_random_uuid(),
  competition_id uuid not null references public.competitions (id) on delete cascade,
  event_catalog_id uuid not null references public.events_catalog (id),
  round public.race_round not null default 'timed_final',
  is_relay boolean not null default false,
  heat integer,
  lane integer,
  created_at timestamptz not null default now()
);

create index races_event_idx on public.races (event_catalog_id);
create index races_competition_idx on public.races (competition_id);

-- ---------------------------------------------------------------------------
-- Performances
-- ---------------------------------------------------------------------------
create table public.performances (
  id uuid primary key default gen_random_uuid(),
  swimmer_id uuid not null references public.profiles (id) on delete cascade,
  race_id uuid not null references public.races (id) on delete cascade,
  event_catalog_id uuid not null references public.events_catalog (id),
  time_ms integer not null check (time_ms > 0),
  seed_time_ms integer check (seed_time_ms is null or seed_time_ms > 0),
  reaction_time_ms integer check (reaction_time_ms is null or reaction_time_ms >= 0),
  splits jsonb,
  dq boolean not null default false,
  dq_reason public.dq_reason,
  meet_level public.meet_level not null,
  course public.course not null,
  competition_date date not null,
  seasonal_age_at_meet integer,
  is_relay boolean not null default false,
  relay_leg_position smallint check (
    relay_leg_position is null or (relay_leg_position between 1 and 4)
  ),
  verification_status public.verification_status not null default 'pending',
  verified_by uuid references public.profiles (id),
  verified_at timestamptz,
  is_personal_best boolean not null default false,
  open_event_index numeric(10, 3),
  age_adjusted_event_index numeric(10, 3),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (
    (dq = false and dq_reason is null)
    or (dq = true and dq_reason is not null)
  ),
  check (
    (is_relay = false and relay_leg_position is null)
    or (is_relay = true)
  )
);

create index performances_swimmer_idx on public.performances (swimmer_id);
create index performances_event_idx on public.performances (event_catalog_id);
create index performances_verified_idx
  on public.performances (verification_status, dq)
  where verification_status = 'verified' and dq = false;
create index performances_meet_level_idx on public.performances (meet_level);
create index performances_course_idx on public.performances (course);

-- ---------------------------------------------------------------------------
-- Composite indices per swimmer
-- ---------------------------------------------------------------------------
create table public.swimmer_indices (
  swimmer_id uuid primary key references public.profiles (id) on delete cascade,
  open_index numeric(10, 3),
  age_adjusted_index numeric(10, 3),
  events_counted integer not null default 0,
  last_computed_at timestamptz,
  computation_notes text
);

-- ---------------------------------------------------------------------------
-- Personal bests (course-specific, never blended)
-- ---------------------------------------------------------------------------
create table public.personal_bests (
  id uuid primary key default gen_random_uuid(),
  swimmer_id uuid not null references public.profiles (id) on delete cascade,
  event_catalog_id uuid not null references public.events_catalog (id),
  performance_id uuid not null references public.performances (id) on delete cascade,
  time_ms integer not null,
  course public.course not null,
  achieved_on date not null,
  unique (swimmer_id, event_catalog_id)
);

-- ---------------------------------------------------------------------------
-- Recruiting / scholarship standards (seed data — cuts change yearly)
-- ---------------------------------------------------------------------------
create table public.recruiting_standards (
  id uuid primary key default gen_random_uuid(),
  tier public.ncaa_tier not null,
  gender public.gender not null,
  event_catalog_id uuid not null references public.events_catalog (id) on delete cascade,
  cut_time_ms integer not null check (cut_time_ms > 0),
  label text not null,
  source text not null default 'seed — sample public cuts; update yearly',
  season_year integer,
  unique (tier, gender, event_catalog_id)
);

-- ---------------------------------------------------------------------------
-- Scholarship profiles
-- ---------------------------------------------------------------------------
create table public.scholarship_profiles (
  swimmer_id uuid primary key references public.profiles (id) on delete cascade,
  is_public boolean not null default true,
  graduating_year integer,
  gpa numeric(3, 2),
  intended_majors text[],
  highlight_notes text,
  standards_met jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- App config (season boundary, decay, meet weights)
-- ---------------------------------------------------------------------------
create table public.app_config (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

insert into public.app_config (key, value) values
  ('season_boundary', '{"month": 9, "day": 1}'::jsonb),
  ('index_top_n', '5'::jsonb),
  ('recency_half_life_days', '365'::jsonb),
  (
    'meet_level_weights',
    '{
      "dual": 0.7,
      "invitational": 0.85,
      "sectional": 1.0,
      "state": 1.1,
      "national": 1.25,
      "international": 1.35,
      "olympic_trials": 1.5
    }'::jsonb
  ),
  ('splits_tolerance_ms', '100'::jsonb);

-- ---------------------------------------------------------------------------
-- Helpers: seasonal age
-- ---------------------------------------------------------------------------
create or replace function public.compute_seasonal_age(
  dob date,
  reference_date date default current_date,
  boundary_month integer default 9,
  boundary_day integer default 1
) returns integer
language plpgsql
immutable
as $$
declare
  season_year integer;
  boundary date;
begin
  if dob is null then
    return null;
  end if;
  -- Seasonal age = age on the most recent season boundary on/before reference_date
  if (extract(month from reference_date)::int > boundary_month)
     or (
       extract(month from reference_date)::int = boundary_month
       and extract(day from reference_date)::int >= boundary_day
     )
  then
    season_year := extract(year from reference_date)::int;
  else
    season_year := extract(year from reference_date)::int - 1;
  end if;
  boundary := make_date(season_year, boundary_month, boundary_day);
  return date_part('year', age(boundary, dob))::integer;
end;
$$;

create or replace function public.age_group_label(seasonal_age integer)
returns text
language sql
immutable
as $$
  select case
    when seasonal_age is null then null
    when seasonal_age <= 8 then '8&U'
    when seasonal_age <= 10 then '9-10'
    when seasonal_age <= 12 then '11-12'
    when seasonal_age <= 14 then '13-14'
    when seasonal_age <= 16 then '15-16'
    when seasonal_age <= 18 then '17-18'
    else 'Open'
  end;
$$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

create trigger performances_updated_at
  before update on public.performances
  for each row execute function public.set_updated_at();
