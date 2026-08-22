import { DEMO_EVENTS } from '$lib/demo/data';
import type { Actions, PageServerLoad } from './$types';
import { fail } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ locals }) => {
	let events = DEMO_EVENTS;
	if (!locals.demoMode && locals.supabase) {
		const { data } = await locals.supabase
			.from('events_catalog')
			.select('id, stroke, distance_m, course, is_relay, label')
			.order('distance_m');
		if (data?.length) events = data;
	}
	return {
		events,
		canSubmit: Boolean(locals.demoMode || locals.session),
		demoMode: locals.demoMode
	};
};

export const actions: Actions = {
	default: async ({ request, locals }) => {
		if (locals.demoMode) {
			const form = await request.formData();
			const eventId = String(form.get('event_catalog_id') ?? '');
			const timeMs = String(form.get('time_ms') ?? '');
			if (!eventId || !timeMs) {
				return fail(400, { error: 'Pick an event and enter a time.' });
			}
			return {
				success: true,
				message: 'Demo only — swim queued for coach verification (not saved).'
			};
		}

		if (!locals.supabase || !locals.session) {
			return fail(401, { error: 'Sign in required.' });
		}
		return fail(501, { error: 'Live submit not wired in this environment.' });
	}
};
