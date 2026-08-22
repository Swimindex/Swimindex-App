export interface SeasonBoundary {
	month: number;
	day: number;
}

export const DEFAULT_SEASON_BOUNDARY: SeasonBoundary = { month: 9, day: 1 };

/**
 * Seasonal age = age on the most recent season boundary on/before referenceDate.
 * Default boundary Sep 1. Competing on Sep 1 uses the new season age bucket.
 */
export function computeSeasonalAge(
	dateOfBirth: Date | string,
	referenceDate: Date | string = new Date(),
	boundary: SeasonBoundary = DEFAULT_SEASON_BOUNDARY
): number {
	const dob = typeof dateOfBirth === 'string' ? parseDateOnly(dateOfBirth) : dateOfBirth;
	const ref = typeof referenceDate === 'string' ? parseDateOnly(referenceDate) : referenceDate;

	const refYear = ref.getUTCFullYear();
	const onOrAfterBoundary =
		ref.getUTCMonth() + 1 > boundary.month ||
		(ref.getUTCMonth() + 1 === boundary.month && ref.getUTCDate() >= boundary.day);

	const seasonYear = onOrAfterBoundary ? refYear : refYear - 1;
	const boundaryDate = new Date(Date.UTC(seasonYear, boundary.month - 1, boundary.day));

	let age = boundaryDate.getUTCFullYear() - dob.getUTCFullYear();
	const monthDiff = boundaryDate.getUTCMonth() - dob.getUTCMonth();
	if (monthDiff < 0 || (monthDiff === 0 && boundaryDate.getUTCDate() < dob.getUTCDate())) {
		age -= 1;
	}
	return age;
}

export function ageGroupLabel(seasonalAge: number | null | undefined): string | null {
	if (seasonalAge == null) return null;
	if (seasonalAge <= 8) return '8&U';
	if (seasonalAge <= 10) return '9-10';
	if (seasonalAge <= 12) return '11-12';
	if (seasonalAge <= 14) return '13-14';
	if (seasonalAge <= 16) return '15-16';
	if (seasonalAge <= 18) return '17-18';
	return 'Open';
}

function parseDateOnly(value: string): Date {
	const [y, m, d] = value.slice(0, 10).split('-').map(Number);
	return new Date(Date.UTC(y, m - 1, d));
}
