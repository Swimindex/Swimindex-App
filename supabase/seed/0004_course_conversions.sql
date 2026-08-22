-- Seed: course conversion factors (USA Swimming–style multipliers)
-- Used ONLY for optional labeled "converted equivalent" times.
-- NEVER overwrite a swimmer's actual recorded time.
-- ADJUSTABLE SEED DATA.

-- Approximate factors: SCY → LCM, LCM → SCY, SCM ↔ LCM for common distances.
-- Factor applies as: converted = recorded * multiplier

insert into public.course_conversion_factors
  (stroke, distance_m, from_course, to_course, multiplier, source, notes)
values
-- Free
('free', 50, 'SCY', 'LCM', 1.110000, 'seed', 'Approx USA Swimming–style; labeled estimate only'),
('free', 50, 'LCM', 'SCY', 0.901000, 'seed', 'Inverse approx'),
('free', 50, 'SCM', 'LCM', 1.040000, 'seed', null),
('free', 50, 'LCM', 'SCM', 0.961500, 'seed', null),
('free', 50, 'SCY', 'SCM', 1.067000, 'seed', null),
('free', 50, 'SCM', 'SCY', 0.937000, 'seed', null),

('free', 100, 'SCY', 'LCM', 1.110000, 'seed', 'Approx — more turns make SCY faster'),
('free', 100, 'LCM', 'SCY', 0.901000, 'seed', null),
('free', 100, 'SCM', 'LCM', 1.050000, 'seed', null),
('free', 100, 'LCM', 'SCM', 0.952400, 'seed', null),
('free', 100, 'SCY', 'SCM', 1.060000, 'seed', null),
('free', 100, 'SCM', 'SCY', 0.943400, 'seed', null),

('free', 200, 'SCY', 'LCM', 1.110000, 'seed', null),
('free', 200, 'LCM', 'SCY', 0.901000, 'seed', null),
('free', 200, 'SCM', 'LCM', 1.055000, 'seed', null),
('free', 200, 'LCM', 'SCM', 0.947900, 'seed', null),

-- Back
('back', 100, 'SCY', 'LCM', 1.110000, 'seed', null),
('back', 100, 'LCM', 'SCY', 0.901000, 'seed', null),
('back', 100, 'SCM', 'LCM', 1.050000, 'seed', null),
('back', 100, 'LCM', 'SCM', 0.952400, 'seed', null),

-- Breast (slightly different turn advantage)
('breast', 100, 'SCY', 'LCM', 1.120000, 'seed', 'Breast turn advantage larger'),
('breast', 100, 'LCM', 'SCY', 0.893000, 'seed', null),
('breast', 100, 'SCM', 'LCM', 1.055000, 'seed', null),
('breast', 100, 'LCM', 'SCM', 0.947900, 'seed', null),

-- Fly
('fly', 100, 'SCY', 'LCM', 1.110000, 'seed', null),
('fly', 100, 'LCM', 'SCY', 0.901000, 'seed', null),
('fly', 100, 'SCM', 'LCM', 1.050000, 'seed', null),
('fly', 100, 'LCM', 'SCM', 0.952400, 'seed', null),

-- IM
('im', 200, 'SCY', 'LCM', 1.115000, 'seed', null),
('im', 200, 'LCM', 'SCY', 0.897000, 'seed', null),
('im', 200, 'SCM', 'LCM', 1.055000, 'seed', null),
('im', 200, 'LCM', 'SCM', 0.947900, 'seed', null)
on conflict (stroke, distance_m, from_course, to_course) do update
set multiplier = excluded.multiplier,
    notes = excluded.notes;
