import { DEFAULT_MEET_WEIGHTS, type MeetLevel } from '$lib/types/swim';

/**
 * World Aquatics points-table style:
 * event_index = 1000 * (standard_time / swimmer_time)^3
 */
export function eventIndexPoints(
	standardTimeMs: number | null | undefined,
	swimmerTimeMs: number | null | undefined
): number | null {
	if (
		standardTimeMs == null ||
		swimmerTimeMs == null ||
		standardTimeMs <= 0 ||
		swimmerTimeMs <= 0
	) {
		return null;
	}
	const points = 1000 * Math.pow(standardTimeMs / swimmerTimeMs, 3);
	return Math.round(points * 1000) / 1000;
}

export function recencyWeight(
	competitionDate: Date | string,
	halfLifeDays = 365,
	asOf: Date = new Date()
): number {
	const meet =
		typeof competitionDate === 'string'
			? new Date(competitionDate.slice(0, 10) + 'T00:00:00Z')
			: competitionDate;
	const days = Math.max(0, (asOf.getTime() - meet.getTime()) / 86_400_000);
	return Math.pow(0.5, days / halfLifeDays);
}

export function meetLevelWeight(
	level: MeetLevel,
	weights: Record<MeetLevel, number> = DEFAULT_MEET_WEIGHTS
): number {
	return weights[level] ?? 1;
}

export interface EventIndexCandidate {
	eventCatalogId: string;
	eventIndex: number;
	competitionDate: string;
	meetLevel: MeetLevel;
}

export function compositeIndex(
	candidates: EventIndexCandidate[],
	opts: {
		topN?: number;
		halfLifeDays?: number;
		meetWeights?: Record<MeetLevel, number>;
	} = {}
): number | null {
	const topN = opts.topN ?? 5;
	const halfLife = opts.halfLifeDays ?? 365;
	const weights = opts.meetWeights ?? DEFAULT_MEET_WEIGHTS;

	const bestByEvent = new Map<string, EventIndexCandidate>();
	for (const c of candidates) {
		const prev = bestByEvent.get(c.eventCatalogId);
		if (!prev || c.eventIndex > prev.eventIndex) {
			bestByEvent.set(c.eventCatalogId, c);
		}
	}

	const ranked = [...bestByEvent.values()]
		.sort((a, b) => b.eventIndex - a.eventIndex)
		.slice(0, topN);

	if (ranked.length === 0) return null;

	let score = 0;
	let wSum = 0;
	for (const r of ranked) {
		const w = recencyWeight(r.competitionDate, halfLife) * meetLevelWeight(r.meetLevel, weights);
		score += r.eventIndex * w;
		wSum += w;
	}
	if (wSum <= 0) return null;
	return Math.round((score / wSum) * 1000) / 1000;
}
