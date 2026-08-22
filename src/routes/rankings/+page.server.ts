import { DEMO_RANKINGS } from '$lib/demo/data';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals, url }) => {
	const course = url.searchParams.get('course');
	const mode = url.searchParams.get('mode') === 'age_adjusted' ? 'age_adjusted' : 'open';

	if (locals.supabase) {
		const { data } = await locals.supabase
			.from('swimmer_indices')
			.select(
				`
				open_index,
				age_adjusted_index,
				profiles!inner ( username, display_name, club_name, region, seasonal_age )
			`
			)
			.order(mode === 'open' ? 'open_index' : 'age_adjusted_index', { ascending: false })
			.limit(100);

		if (data && data.length > 0) {
			return {
				mode,
				rankings: data.map((row, i) => {
					const p = Array.isArray(row.profiles) ? row.profiles[0] : row.profiles;
					return {
						rank: i + 1,
						username: p?.username ?? 'unknown',
						display_name: p?.display_name ?? 'Unknown',
						club_name: p?.club_name ?? '—',
						region: p?.region ?? '—',
						seasonal_age: p?.seasonal_age ?? null,
						open_index: Number(row.open_index ?? 0),
						age_adjusted_index: Number(row.age_adjusted_index ?? 0),
						course: (course as 'SCY' | 'SCM' | 'LCM') || 'SCY',
						top_event: '—',
						meet_level: null as null
					};
				}),
				source: 'supabase' as const
			};
		}
	}

	return {
		mode,
		rankings: DEMO_RANKINGS.map((r) => ({ ...r, meet_level: null as null })),
		source: 'demo' as const
	};
};
