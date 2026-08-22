import { DEMO_EVENTS } from '$lib/demo/data';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
	let events = DEMO_EVENTS;
	if (locals.supabase) {
		const { data } = await locals.supabase
			.from('events_catalog')
			.select('id, stroke, distance_m, course, is_relay, label')
			.order('distance_m');
		if (data?.length) events = data;
	}
	return {
		events,
		canSubmit: Boolean(locals.session)
	};
};
