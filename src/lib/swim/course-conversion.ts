import type { Course, Stroke } from '$lib/types/swim';

/**
 * Apply a conversion multiplier to produce an *estimated* equivalent time.
 * Callers MUST label the result as converted/estimated — never as recorded.
 */
export function convertCourseTime(
	timeMs: number,
	multiplier: number | null | undefined
): number | null {
	if (multiplier == null || multiplier <= 0 || timeMs <= 0) return null;
	return Math.round(timeMs * multiplier);
}

export function conversionKey(
	stroke: Stroke,
	distanceM: number,
	from: Course,
	to: Course
): string {
	return `${stroke}:${distanceM}:${from}->${to}`;
}
