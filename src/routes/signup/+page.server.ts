import { fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => ({
	authEnabled: Boolean(locals.supabase)
});

export const actions: Actions = {
	default: async ({ request, locals, url }) => {
		if (!locals.supabase) return fail(503, { error: 'Supabase is not configured.' });
		const form = await request.formData();
		const email = String(form.get('email') ?? '');
		const username = String(form.get('username') ?? '');
		const display_name = String(form.get('display_name') ?? '');
		const role = String(form.get('role') ?? 'swimmer');
		const date_of_birth = String(form.get('date_of_birth') ?? '') || null;

		if (!email || !username || !display_name) {
			return fail(400, { error: 'Email, username, and display name are required.' });
		}

		const { error } = await locals.supabase.auth.signInWithOtp({
			email,
			options: {
				emailRedirectTo: `${url.origin}/auth/callback`,
				data: { username, display_name, role, date_of_birth }
			}
		});
		if (error) return fail(400, { error: error.message });
		return { success: true };
	}
};
