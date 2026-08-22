import { DEMO_PROFILE, DEMO_STANDARDS_MET } from '$lib/demo/data';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ params, locals }) => {
	if (locals.supabase) {
		const { data: profile } = await locals.supabase
			.from('profiles')
			.select('*')
			.eq('username', params.username)
			.maybeSingle();

		if (profile) {
			const { data: scholarship } = await locals.supabase
				.from('scholarship_profiles')
				.select('standards_met')
				.eq('swimmer_id', profile.id)
				.maybeSingle();

			const standards = Array.isArray(scholarship?.standards_met)
				? scholarship.standards_met
				: [];

			return {
				profile,
				standards: standards.map((s: Record<string, unknown>) => ({
					label: String(s.label ?? ''),
					tier: String(s.tier ?? 'D1_B'),
					event: String(s.event ?? ''),
					cut_time_ms: Number(s.cut_time_ms ?? 0),
					pb_time_ms: Number(s.pb_time_ms ?? 0)
				})),
				source: 'supabase' as const
			};
		}
	}

	return {
		profile: DEMO_PROFILE,
		standards: DEMO_STANDARDS_MET,
		source: 'demo' as const
	};
};
