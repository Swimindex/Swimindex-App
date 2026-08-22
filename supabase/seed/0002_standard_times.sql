-- Seed: elite/open standard times (approximate World Aquatics base times)
-- ADJUSTABLE SEED DATA — update as world records / federation tables change.
-- Times in milliseconds.

create or replace function public._seed_std(
  p_stroke public.stroke,
  p_distance integer,
  p_course public.course,
  p_gender public.gender,
  p_time_ms integer
) returns void
language plpgsql
as $$
declare
  eid uuid;
begin
  select id into eid from public.events_catalog
  where stroke = p_stroke and distance_m = p_distance and course = p_course and is_relay = false;
  if eid is null then return; end if;
  insert into public.standard_times (event_catalog_id, gender, time_ms, source, notes)
  values (
    eid, p_gender, p_time_ms, 'seed',
    'Approximate elite base time — replace with official WA points table base'
  )
  on conflict (event_catalog_id, gender) do update set time_ms = excluded.time_ms;
end;
$$;

-- LCM Men
select public._seed_std('free', 50, 'LCM', 'M', 21110);
select public._seed_std('free', 100, 'LCM', 'M', 46660);
select public._seed_std('free', 200, 'LCM', 'M', 102000);
select public._seed_std('free', 400, 'LCM', 'M', 220080);
select public._seed_std('free', 800, 'LCM', 'M', 452120);
select public._seed_std('free', 1500, 'LCM', 'M', 871020);
select public._seed_std('back', 50, 'LCM', 'M', 23900);
select public._seed_std('back', 100, 'LCM', 'M', 51500);
select public._seed_std('back', 200, 'LCM', 'M', 111920);
select public._seed_std('breast', 50, 'LCM', 'M', 25500);
select public._seed_std('breast', 100, 'LCM', 'M', 56400);
select public._seed_std('breast', 200, 'LCM', 'M', 123350);
select public._seed_std('fly', 50, 'LCM', 'M', 22270);
select public._seed_std('fly', 100, 'LCM', 'M', 49200);
select public._seed_std('fly', 200, 'LCM', 'M', 110340);
select public._seed_std('im', 200, 'LCM', 'M', 114000);
select public._seed_std('im', 400, 'LCM', 'M', 243030);

-- LCM Women
select public._seed_std('free', 50, 'LCM', 'F', 23580);
select public._seed_std('free', 100, 'LCM', 'F', 51500);
select public._seed_std('free', 200, 'LCM', 'F', 112800);
select public._seed_std('free', 400, 'LCM', 'F', 235380);
select public._seed_std('free', 800, 'LCM', 'F', 484000);
select public._seed_std('free', 1500, 'LCM', 'F', 920000);
select public._seed_std('back', 50, 'LCM', 'F', 26800);
select public._seed_std('back', 100, 'LCM', 'F', 57100);
select public._seed_std('back', 200, 'LCM', 'F', 123000);
select public._seed_std('breast', 50, 'LCM', 'F', 29000);
select public._seed_std('breast', 100, 'LCM', 'F', 64100);
select public._seed_std('breast', 200, 'LCM', 'F', 138000);
select public._seed_std('fly', 50, 'LCM', 'F', 24500);
select public._seed_std('fly', 100, 'LCM', 'F', 55100);
select public._seed_std('fly', 200, 'LCM', 'F', 121000);
select public._seed_std('im', 200, 'LCM', 'F', 126000);
select public._seed_std('im', 400, 'LCM', 'F', 268000);

-- SCY Men
select public._seed_std('free', 50, 'SCY', 'M', 18400);
select public._seed_std('free', 100, 'SCY', 'M', 40200);
select public._seed_std('free', 200, 'SCY', 'M', 89000);
select public._seed_std('free', 500, 'SCY', 'M', 242000);
select public._seed_std('free', 1000, 'SCY', 'M', 510000);
select public._seed_std('free', 1650, 'SCY', 'M', 855000);
select public._seed_std('back', 50, 'SCY', 'M', 20500);
select public._seed_std('back', 100, 'SCY', 'M', 43800);
select public._seed_std('back', 200, 'SCY', 'M', 96000);
select public._seed_std('breast', 50, 'SCY', 'M', 22800);
select public._seed_std('breast', 100, 'SCY', 'M', 49500);
select public._seed_std('breast', 200, 'SCY', 'M', 108000);
select public._seed_std('fly', 50, 'SCY', 'M', 19800);
select public._seed_std('fly', 100, 'SCY', 'M', 43000);
select public._seed_std('fly', 200, 'SCY', 'M', 98000);
select public._seed_std('im', 100, 'SCY', 'M', 45000);
select public._seed_std('im', 200, 'SCY', 'M', 99000);
select public._seed_std('im', 400, 'SCY', 'M', 214000);

-- SCY Women
select public._seed_std('free', 50, 'SCY', 'F', 21000);
select public._seed_std('free', 100, 'SCY', 'F', 45500);
select public._seed_std('free', 200, 'SCY', 'F', 100000);
select public._seed_std('free', 500, 'SCY', 'F', 268000);
select public._seed_std('free', 1000, 'SCY', 'F', 560000);
select public._seed_std('free', 1650, 'SCY', 'F', 930000);
select public._seed_std('back', 50, 'SCY', 'F', 23500);
select public._seed_std('back', 100, 'SCY', 'F', 49500);
select public._seed_std('back', 200, 'SCY', 'F', 108000);
select public._seed_std('breast', 50, 'SCY', 'F', 26000);
select public._seed_std('breast', 100, 'SCY', 'F', 56000);
select public._seed_std('breast', 200, 'SCY', 'F', 122000);
select public._seed_std('fly', 50, 'SCY', 'F', 22500);
select public._seed_std('fly', 100, 'SCY', 'F', 49000);
select public._seed_std('fly', 200, 'SCY', 'F', 110000);
select public._seed_std('im', 100, 'SCY', 'F', 52000);
select public._seed_std('im', 200, 'SCY', 'F', 112000);
select public._seed_std('im', 400, 'SCY', 'F', 240000);

-- SCM Men
select public._seed_std('free', 50, 'SCM', 'M', 20050);
select public._seed_std('free', 100, 'SCM', 'M', 44400);
select public._seed_std('free', 200, 'SCM', 'M', 98000);
select public._seed_std('free', 400, 'SCM', 'M', 210000);
select public._seed_std('free', 800, 'SCM', 'M', 435000);
select public._seed_std('free', 1500, 'SCM', 'M', 840000);
select public._seed_std('back', 50, 'SCM', 'M', 22500);
select public._seed_std('back', 100, 'SCM', 'M', 48500);
select public._seed_std('back', 200, 'SCM', 'M', 105000);
select public._seed_std('breast', 50, 'SCM', 'M', 25000);
select public._seed_std('breast', 100, 'SCM', 'M', 54500);
select public._seed_std('breast', 200, 'SCM', 'M', 120000);
select public._seed_std('fly', 50, 'SCM', 'M', 21500);
select public._seed_std('fly', 100, 'SCM', 'M', 47500);
select public._seed_std('fly', 200, 'SCM', 'M', 105000);
select public._seed_std('im', 100, 'SCM', 'M', 50000);
select public._seed_std('im', 200, 'SCM', 'M', 108000);
select public._seed_std('im', 400, 'SCM', 'M', 235000);

-- SCM Women
select public._seed_std('free', 50, 'SCM', 'F', 22500);
select public._seed_std('free', 100, 'SCM', 'F', 50000);
select public._seed_std('free', 200, 'SCM', 'F', 110000);
select public._seed_std('free', 400, 'SCM', 'F', 230000);
select public._seed_std('free', 800, 'SCM', 'F', 475000);
select public._seed_std('free', 1500, 'SCM', 'F', 900000);
select public._seed_std('back', 50, 'SCM', 'F', 25500);
select public._seed_std('back', 100, 'SCM', 'F', 55000);
select public._seed_std('back', 200, 'SCM', 'F', 118000);
select public._seed_std('breast', 50, 'SCM', 'F', 28500);
select public._seed_std('breast', 100, 'SCM', 'F', 62000);
select public._seed_std('breast', 200, 'SCM', 'F', 135000);
select public._seed_std('fly', 50, 'SCM', 'F', 24000);
select public._seed_std('fly', 100, 'SCM', 'F', 53500);
select public._seed_std('fly', 200, 'SCM', 'F', 118000);
select public._seed_std('im', 100, 'SCM', 'F', 57000);
select public._seed_std('im', 200, 'SCM', 'F', 122000);
select public._seed_std('im', 400, 'SCM', 'F', 260000);

drop function public._seed_std(public.stroke, integer, public.course, public.gender, integer);
