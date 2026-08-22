import type { Course } from '$lib/types/swim';

export type PaceProfile = 'even' | 'negative' | 'positive' | 'unknown';

export function splitsSum(splits: number[]): number {
	return splits.reduce((a, b) => a + b, 0);
}

export function splitsMatchFinal(
	splits: number[],
	finalTimeMs: number,
	toleranceMs = 100
): { ok: boolean; sum: number; delta: number } {
	const sum = splitsSum(splits);
	const delta = sum - finalTimeMs;
	return { ok: Math.abs(delta) <= toleranceMs, sum, delta };
}

export function expectedSplitCount(distanceM: number, _course: Course): number {
	const unit = 50;
	if (distanceM % unit === 0) return Math.max(1, distanceM / unit);
	return Math.max(1, Math.round(distanceM / 100));
}

export function pacingProfile(splits: number[]): PaceProfile {
	if (splits.length < 2) return 'unknown';
	const mid = Math.floor(splits.length / 2);
	const first = splits.slice(0, mid).reduce((a, b) => a + b, 0);
	const second = splits.slice(mid).reduce((a, b) => a + b, 0);
	const tolerance = 50;
	if (Math.abs(first - second) <= tolerance) return 'even';
	return second < first ? 'negative' : 'positive';
}
