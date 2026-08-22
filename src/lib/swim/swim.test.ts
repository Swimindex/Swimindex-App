import { describe, expect, it } from 'vitest';
import { formatSwimTime, parseSwimTime } from '$lib/swim/time';
import {
	expectedSplitCount,
	pacingProfile,
	splitsMatchFinal,
	splitsSum
} from '$lib/swim/splits';
import { compositeIndex, eventIndexPoints } from '$lib/swim/index-calc';
import { ageGroupLabel, computeSeasonalAge } from '$lib/swim/seasonal-age';
import { convertCourseTime } from '$lib/swim/course-conversion';

describe('parseSwimTime / formatSwimTime', () => {
	it('parses sub-minute times', () => {
		expect(parseSwimTime('28.45')).toBe(28450);
		expect(parseSwimTime('59.99')).toBe(59990);
	});

	it('parses mm:ss.ss', () => {
		expect(parseSwimTime('1:02.31')).toBe(62310);
		expect(parseSwimTime('2:00.00')).toBe(120000);
	});

	it('rejects invalid seconds', () => {
		expect(parseSwimTime('1:60.00')).toBeNull();
		expect(parseSwimTime('abc')).toBeNull();
	});

	it('round-trips format', () => {
		expect(formatSwimTime(28450)).toBe('28.45');
		expect(formatSwimTime(62310)).toBe('1:02.31');
	});
});

describe('splits', () => {
	it('sums and matches final within tolerance', () => {
		const splits = [27200, 27600];
		expect(splitsSum(splits)).toBe(54800);
		expect(splitsMatchFinal(splits, 54800, 100).ok).toBe(true);
		expect(splitsMatchFinal(splits, 55000, 100).ok).toBe(false);
	});

	it('detects pacing', () => {
		expect(pacingProfile([28000, 27000])).toBe('negative');
		expect(pacingProfile([27000, 28000])).toBe('positive');
		expect(pacingProfile([27500, 27500])).toBe('even');
	});

	it('expected split count for 200 SCY', () => {
		expect(expectedSplitCount(200, 'SCY')).toBe(4);
	});
});

describe('index formula', () => {
	it('equals 1000 when time matches standard', () => {
		expect(eventIndexPoints(50000, 50000)).toBe(1000);
	});

	it('is above 1000 when faster than standard', () => {
		const pts = eventIndexPoints(50000, 48000)!;
		expect(pts).toBeGreaterThan(1000);
	});

	it('excludes empty composite', () => {
		expect(compositeIndex([])).toBeNull();
	});

	it('weights top events', () => {
		const score = compositeIndex([
			{
				eventCatalogId: 'a',
				eventIndex: 900,
				competitionDate: '2026-01-01',
				meetLevel: 'national'
			},
			{
				eventCatalogId: 'b',
				eventIndex: 800,
				competitionDate: '2026-01-01',
				meetLevel: 'dual'
			}
		]);
		expect(score).not.toBeNull();
		expect(score!).toBeGreaterThan(800);
		expect(score!).toBeLessThanOrEqual(900);
	});
});

describe('seasonal age', () => {
	it('uses Sep 1 boundary', () => {
		expect(computeSeasonalAge('2010-09-02', '2025-09-01')).toBe(14);
		expect(computeSeasonalAge('2010-09-01', '2025-09-01')).toBe(15);
	});

	it('handles pre-boundary dates in prior season year', () => {
		expect(computeSeasonalAge('2010-03-01', '2025-08-31')).toBe(14);
		expect(computeSeasonalAge('2010-03-01', '2025-09-01')).toBe(15);
	});

	it('labels age groups', () => {
		expect(ageGroupLabel(12)).toBe('11-12');
		expect(ageGroupLabel(19)).toBe('Open');
	});
});

describe('course conversion', () => {
	it('applies multiplier as estimate only', () => {
		expect(convertCourseTime(50000, 1.11)).toBe(55500);
		expect(convertCourseTime(50000, null)).toBeNull();
	});
});
