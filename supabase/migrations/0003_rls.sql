-- Row Level Security

alter table public.profiles enable row level security;
alter table public.coach_swimmers enable row level security;
alter table public.competitions enable row level security;
alter table public.races enable row level security;
alter table public.performances enable row level security;
alter table public.swimmer_indices enable row level security;
alter table public.personal_bests enable row level security;
alter table public.scholarship_profiles enable row level security;
alter table public.events_catalog enable row level security;
alter table public.standard_times enable row level security;
alter table public.age_group_standard_times enable row level security;
alter table public.course_conversion_factors enable row level security;
alter table public.recruiting_standards enable row level security;
alter table public.app_config enable row level security;

-- Reference tables: public read
create policy "events_catalog_read" on public.events_catalog
  for select using (true);
create policy "standard_times_read" on public.standard_times
  for select using (true);
create policy "age_group_standards_read" on public.age_group_standard_times
  for select using (true);
create policy "course_conversion_read" on public.course_conversion_factors
  for select using (true);
create policy "recruiting_standards_read" on public.recruiting_standards
  for select using (true);
create policy "app_config_read" on public.app_config
  for select using (true);

-- Admin write on reference tables
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

create or replace function public.is_coach()
returns boolean
language sql
stable
security definer
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role in ('coach', 'admin')
  );
$$;

create policy "events_catalog_admin_write" on public.events_catalog
  for all using (public.is_admin()) with check (public.is_admin());
create policy "standard_times_admin_write" on public.standard_times
  for all using (public.is_admin()) with check (public.is_admin());
create policy "age_group_standards_admin_write" on public.age_group_standard_times
  for all using (public.is_admin()) with check (public.is_admin());
create policy "course_conversion_admin_write" on public.course_conversion_factors
  for all using (public.is_admin()) with check (public.is_admin());
create policy "recruiting_standards_admin_write" on public.recruiting_standards
  for all using (public.is_admin()) with check (public.is_admin());
create policy "app_config_admin_write" on public.app_config
  for all using (public.is_admin()) with check (public.is_admin());

-- Profiles
create policy "profiles_public_read" on public.profiles
  for select using (true);
create policy "profiles_self_update" on public.profiles
  for update using (auth.uid() = id);
create policy "profiles_self_insert" on public.profiles
  for insert with check (auth.uid() = id);

-- Coach links
create policy "coach_swimmers_read" on public.coach_swimmers
  for select using (
    auth.uid() = coach_id or auth.uid() = swimmer_id or public.is_admin()
  );
create policy "coach_swimmers_write" on public.coach_swimmers
  for all using (auth.uid() = coach_id or public.is_admin())
  with check (auth.uid() = coach_id or public.is_admin());

-- Competitions / races: public read, authenticated write
create policy "competitions_read" on public.competitions for select using (true);
create policy "competitions_write" on public.competitions
  for insert with check (auth.uid() is not null);
create policy "competitions_update" on public.competitions
  for update using (created_by = auth.uid() or public.is_admin());

create policy "races_read" on public.races for select using (true);
create policy "races_write" on public.races
  for insert with check (auth.uid() is not null);

-- Performances
create policy "performances_read" on public.performances for select using (true);
create policy "performances_insert" on public.performances
  for insert with check (
    auth.uid() = swimmer_id
    or exists (
      select 1 from public.coach_swimmers
      where coach_id = auth.uid() and swimmer_id = performances.swimmer_id
    )
    or public.is_admin()
  );
create policy "performances_update" on public.performances
  for update using (
    public.is_coach()
    or auth.uid() = swimmer_id
    or public.is_admin()
  );

-- Indices & PBs public
create policy "indices_read" on public.swimmer_indices for select using (true);
create policy "pbs_read" on public.personal_bests for select using (true);

-- Scholarship profiles
create policy "scholarship_public_read" on public.scholarship_profiles
  for select using (is_public = true or auth.uid() = swimmer_id or public.is_admin());
create policy "scholarship_self_write" on public.scholarship_profiles
  for all using (auth.uid() = swimmer_id or public.is_admin())
  with check (auth.uid() = swimmer_id or public.is_admin());

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  uname text;
begin
  uname := coalesce(
    new.raw_user_meta_data ->> 'username',
    split_part(new.email, '@', 1)
  );
  insert into public.profiles (id, username, display_name, role, gender, date_of_birth)
  values (
    new.id,
    uname,
    coalesce(new.raw_user_meta_data ->> 'display_name', uname),
    coalesce((new.raw_user_meta_data ->> 'role')::public.user_role, 'swimmer'),
    (new.raw_user_meta_data ->> 'gender')::public.gender,
    (new.raw_user_meta_data ->> 'date_of_birth')::date
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
