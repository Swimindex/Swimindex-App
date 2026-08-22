-- Seed: age-group standard times (USA Swimming–style motivational / AG)
-- ADJUSTABLE SEED DATA — feeds Age-Adjusted Index.
-- Using a simplified "AAAA" band per age group for core events.

create or replace function public._seed_ag(
  p_stroke public.stroke,
  p_distance integer,
  p_course public.course,
  p_gender public.gender,
  p_age_min integer,
  p_age_max integer,
  p_time_ms integer,
  p_label text default 'AAAA'
) returns void
language plpgsql
as $$
declare
  eid uuid;
begin
  select id into eid from public.events_catalog
  where stroke = p_stroke and distance_m = p_distance and course = p_course and is_relay = false;
  if eid is null then return; end if;
  insert into public.age_group_standard_times (
    event_catalog_id, gender, age_min, age_max, time_ms, standard_label, source
  ) values (
    eid, p_gender, p_age_min, p_age_max, p_time_ms, p_label,
    'seed — USA Swimming–style AG motivational approx'
  )
  on conflict (event_catalog_id, gender, age_min, age_max, standard_label)
  do update set time_ms = excluded.time_ms;
end;
$$;

-- SCY 100 Free — Men age bands (slower standards for younger ages)
select public._seed_ag('free', 100, 'SCY', 'M', 9, 10, 70000);
select public._seed_ag('free', 100, 'SCY', 'M', 11, 12, 58000);
select public._seed_ag('free', 100, 'SCY', 'M', 13, 14, 50000);
select public._seed_ag('free', 100, 'SCY', 'M', 15, 16, 46000);
select public._seed_ag('free', 100, 'SCY', 'M', 17, 18, 43000);

select public._seed_ag('free', 100, 'SCY', 'F', 9, 10, 72000);
select public._seed_ag('free', 100, 'SCY', 'F', 11, 12, 60000);
select public._seed_ag('free', 100, 'SCY', 'F', 13, 14, 53000);
select public._seed_ag('free', 100, 'SCY', 'F', 15, 16, 49000);
select public._seed_ag('free', 100, 'SCY', 'F', 17, 18, 47000);

-- SCY 50 Free
select public._seed_ag('free', 50, 'SCY', 'M', 9, 10, 32000);
select public._seed_ag('free', 50, 'SCY', 'M', 11, 12, 26000);
select public._seed_ag('free', 50, 'SCY', 'M', 13, 14, 22500);
select public._seed_ag('free', 50, 'SCY', 'M', 15, 16, 20500);
select public._seed_ag('free', 50, 'SCY', 'M', 17, 18, 19500);

select public._seed_ag('free', 50, 'SCY', 'F', 9, 10, 33000);
select public._seed_ag('free', 50, 'SCY', 'F', 11, 12, 27500);
select public._seed_ag('free', 50, 'SCY', 'F', 13, 14, 24500);
select public._seed_ag('free', 50, 'SCY', 'F', 15, 16, 22500);
select public._seed_ag('free', 50, 'SCY', 'F', 17, 18, 21500);

-- SCY 200 Free
select public._seed_ag('free', 200, 'SCY', 'M', 11, 12, 130000);
select public._seed_ag('free', 200, 'SCY', 'M', 13, 14, 110000);
select public._seed_ag('free', 200, 'SCY', 'M', 15, 16, 100000);
select public._seed_ag('free', 200, 'SCY', 'M', 17, 18, 95000);
select public._seed_ag('free', 200, 'SCY', 'F', 11, 12, 135000);
select public._seed_ag('free', 200, 'SCY', 'F', 13, 14, 118000);
select public._seed_ag('free', 200, 'SCY', 'F', 15, 16, 108000);
select public._seed_ag('free', 200, 'SCY', 'F', 17, 18, 103000);

-- SCY 100 Back / Breast / Fly / 200 IM — representative bands
select public._seed_ag('back', 100, 'SCY', 'M', 13, 14, 58000);
select public._seed_ag('back', 100, 'SCY', 'M', 15, 16, 52000);
select public._seed_ag('back', 100, 'SCY', 'M', 17, 18, 48000);
select public._seed_ag('back', 100, 'SCY', 'F', 13, 14, 62000);
select public._seed_ag('back', 100, 'SCY', 'F', 15, 16, 56000);
select public._seed_ag('back', 100, 'SCY', 'F', 17, 18, 53000);

select public._seed_ag('breast', 100, 'SCY', 'M', 13, 14, 65000);
select public._seed_ag('breast', 100, 'SCY', 'M', 15, 16, 58000);
select public._seed_ag('breast', 100, 'SCY', 'M', 17, 18, 54000);
select public._seed_ag('breast', 100, 'SCY', 'F', 13, 14, 70000);
select public._seed_ag('breast', 100, 'SCY', 'F', 15, 16, 63000);
select public._seed_ag('breast', 100, 'SCY', 'F', 17, 18, 60000);

select public._seed_ag('fly', 100, 'SCY', 'M', 13, 14, 56000);
select public._seed_ag('fly', 100, 'SCY', 'M', 15, 16, 50000);
select public._seed_ag('fly', 100, 'SCY', 'M', 17, 18, 47000);
select public._seed_ag('fly', 100, 'SCY', 'F', 13, 14, 61000);
select public._seed_ag('fly', 100, 'SCY', 'F', 15, 16, 55000);
select public._seed_ag('fly', 100, 'SCY', 'F', 17, 18, 52000);

select public._seed_ag('im', 200, 'SCY', 'M', 13, 14, 125000);
select public._seed_ag('im', 200, 'SCY', 'M', 15, 16, 112000);
select public._seed_ag('im', 200, 'SCY', 'M', 17, 18, 105000);
select public._seed_ag('im', 200, 'SCY', 'F', 13, 14, 132000);
select public._seed_ag('im', 200, 'SCY', 'F', 15, 16, 120000);
select public._seed_ag('im', 200, 'SCY', 'F', 17, 18, 115000);

-- LCM 100 Free age bands
select public._seed_ag('free', 100, 'LCM', 'M', 13, 14, 58000);
select public._seed_ag('free', 100, 'LCM', 'M', 15, 16, 53000);
select public._seed_ag('free', 100, 'LCM', 'M', 17, 18, 50000);
select public._seed_ag('free', 100, 'LCM', 'F', 13, 14, 62000);
select public._seed_ag('free', 100, 'LCM', 'F', 15, 16, 57000);
select public._seed_ag('free', 100, 'LCM', 'F', 17, 18, 54000);

-- Open adult bucket (19+) uses open standards via age_max high
select public._seed_ag('free', 100, 'SCY', 'M', 19, 99, 40200, 'Open');
select public._seed_ag('free', 100, 'SCY', 'F', 19, 99, 45500, 'Open');
select public._seed_ag('free', 50, 'SCY', 'M', 19, 99, 18400, 'Open');
select public._seed_ag('free', 50, 'SCY', 'F', 19, 99, 21000, 'Open');
select public._seed_ag('free', 100, 'LCM', 'M', 19, 99, 46660, 'Open');
select public._seed_ag('free', 100, 'LCM', 'F', 19, 99, 51500, 'Open');

drop function public._seed_ag(public.stroke, integer, public.course, public.gender, integer, integer, integer, text);
