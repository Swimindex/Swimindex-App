import { fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
	return { authEnabled: Boolean(locals.supabase) };
};

export const actions: Actions = {
	default: async ({ request, locals, url }) => {
		if (!locals.supabase) {
			return fail(503, { error: 'Supabase is not configured.' });
		}
		const form = await request.formData();
		const email = String(form.get('email') ?? '');
		if (!email) return fail(400, { error: 'Email required.' });

		const { error } = await locals.supabase.auth.signInWithOtp({
			email,
			options: { emailRedirectTo: `${url.origin}/auth/callback` }
		});
		if (error) return fail(400, { error: error.message });
		return { success: true };
	}
};
