import { DEMO_PERSONA_COOKIE, personaFromCookie, type DemoPersona } from '$lib/demo/mode';
import { fail, redirect } from '@sveltejs/kit';
import type { Actions } from './$types';

export const actions: Actions = {
	persona: async ({ request, cookies, locals }) => {
		if (!locals.demoMode) {
			return fail(403, { error: 'Demo mode is off.' });
		}
		const form = await request.formData();
		const persona = personaFromCookie(String(form.get('persona') ?? '')) as DemoPersona;
		cookies.set(DEMO_PERSONA_COOKIE, persona, {
			path: '/',
			httpOnly: false,
			sameSite: 'lax',
			maxAge: 60 * 60 * 24 * 30
		});

		// Land on the most relevant screen for the persona
		if (persona === 'admin') throw redirect(303, '/admin');
		if (persona === 'coach') throw redirect(303, '/verify');
		throw redirect(303, '/profile/maya.chen');
	}
};
