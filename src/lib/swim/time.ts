/**
 * Swim time parsing / formatting.
 * Accepts mm:ss.ss or ss.ss (sub-minute, e.g. 28.45 for a 50).
 */

export function parseSwimTime(input: string): number | null {
	const raw = input.trim();
	if (!raw) return null;

	const withMin = /^(\d{1,2}):(\d{2})(?:\.(\d{1,2}))?$/.exec(raw);
	if (withMin) {
		const minutes = Number(withMin[1]);
		const seconds = Number(withMin[2]);
		const hundredths = Number((withMin[3] ?? '0').padEnd(2, '0').slice(0, 2));
		if (seconds >= 60) return null;
		return minutes * 60_000 + seconds * 1_000 + hundredths * 10;
	}

	const secsOnly = /^(\d{1,2})(?:\.(\d{1,2}))?$/.exec(raw);
	if (secsOnly) {
		const seconds = Number(secsOnly[1]);
		const hundredths = Number((secsOnly[2] ?? '0').padEnd(2, '0').slice(0, 2));
		if (seconds >= 60) return null;
		return seconds * 1_000 + hundredths * 10;
	}

	return null;
}

export function formatSwimTime(ms: number | null | undefined): string {
	if (ms == null || !Number.isFinite(ms) || ms < 0) return '—';
	const totalHundredths = Math.round(ms / 10);
	const hundredths = totalHundredths % 100;
	const totalSeconds = Math.floor(totalHundredths / 100);
	const seconds = totalSeconds % 60;
	const minutes = Math.floor(totalSeconds / 60);
	const hh = hundredths.toString().padStart(2, '0');
	const ss = seconds.toString().padStart(2, '0');
	if (minutes === 0) return `${seconds}.${hh}`;
	return `${minutes}:${ss}.${hh}`;
}

export function formatDelta(ms: number): string {
	const sign = ms > 0 ? '+' : ms < 0 ? '−' : '';
	return `${sign}${formatSwimTime(Math.abs(ms))}`;
}

/** Aliases */
export const parseSwimTimeMs = parseSwimTime;
export const formatSwimTimeMs = formatSwimTime;
