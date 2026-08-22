import { DEMO_PBS, DEMO_PROFILE } from '$lib/demo/data';
import type { PageServerLoad } from './$types';
import { error } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ params, locals }) => {
	if (locals.supabase) {
		const { data: profile } = await locals.supabase
			.from('profiles')
			.select('*')
			.eq('username', params.username)
			.maybeSingle();

		if (profile) {
			const { data: pbs } = await locals.supabase
				.from('personal_bests')
				.select('time_ms, course, achieved_on, events_catalog(label), open_event_index:performances(open_event_index)')
				.eq('swimmer_id', profile.id);

			const { data: idx } = await locals.supabase
				.from('swimmer_indices')
				.select('open_index, age_adjusted_index')
				.eq('swimmer_id', profile.id)
				.maybeSingle();

			return {
				profile,
				pbs: (pbs ?? []).map((p) => {
					const ec = Array.isArray(p.events_catalog) ? p.events_catalog[0] : p.events_catalog;
					return {
						event: ec?.label ?? 'Event',
						course: p.course,
						time_ms: p.time_ms,
						achieved_on: p.achieved_on,
						open_index: null as number | null
					};
				}),
				open_index: idx?.open_index != null ? Number(idx.open_index) : null,
				age_adjusted_index: idx?.age_adjusted_index != null ? Number(idx.age_adjusted_index) : null,
				source: 'supabase' as const
			};
		}
	}

	if (params.username !== DEMO_PROFILE.username && params.username !== 'demo') {
		// Still show demo for unknown usernames in offline mode
	}

	return {
		profile: { ...DEMO_PROFILE, username: params.username === 'demo' ? 'maya.chen' : params.username === DEMO_PROFILE.username ? DEMO_PROFILE.username : DEMO_PROFILE.username },
		pbs: DEMO_PBS,
		open_index: 912.4,
		age_adjusted_index: 1048.2,
		source: 'demo' as const
	};
};
