import { DEMO_PENDING } from '$lib/demo/data';
import { fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
	const role = locals.profile?.role;
	const canVerify = role === 'coach' || role === 'admin';

	if (locals.supabase && canVerify) {
		const { data } = await locals.supabase
			.from('performances')
			.select(
				`
				id, time_ms, dq, dq_reason, splits, meet_level, competition_date,
				profiles!performances_swimmer_id_fkey ( display_name ),
				events_catalog ( label ),
				races ( meets ( name ) )
			`
			)
			.eq('verification_status', 'pending')
			.limit(50);

		if (data?.length) {
			return {
				canVerify,
				pending: data.map((p) => {
					const profile = Array.isArray(p.profiles) ? p.profiles[0] : p.profiles;
					const event = Array.isArray(p.events_catalog) ? p.events_catalog[0] : p.events_catalog;
					const race = Array.isArray(p.races) ? p.races[0] : p.races;
					const meet = race && (Array.isArray(race.meets) ? race.meets[0] : race.meets);
					return {
						id: p.id,
						swimmer: profile?.display_name ?? 'Swimmer',
						event: event?.label ?? 'Event',
						time_ms: p.time_ms,
						meet: meet?.name ?? 'Meet',
						meet_level: p.meet_level,
						dq: p.dq,
						dq_reason: p.dq_reason,
						splits: p.splits as number[] | null,
						competition_date: p.competition_date
					};
				})
			};
		}
	}

	return { canVerify: false, pending: DEMO_PENDING };
};

export const actions: Actions = {
	default: async ({ request, locals }) => {
		const role = locals.profile?.role;
		if (!locals.supabase || (role !== 'coach' && role !== 'admin')) {
			return fail(403, { error: 'Forbidden' });
		}
		const form = await request.formData();
		const id = String(form.get('id') ?? '');
		const decision = String(form.get('decision') ?? '');
		if (!id || !['verify', 'reject'].includes(decision)) {
			return fail(400, { error: 'Invalid request' });
		}

		const { error } = await locals.supabase
			.from('performances')
			.update({
				verification_status: decision === 'verify' ? 'verified' : 'rejected',
				verified_by: locals.user?.id,
				verified_at: new Date().toISOString()
			})
			.eq('id', id);

		if (error) return fail(400, { error: error.message });
		return { success: true };
	}
};
