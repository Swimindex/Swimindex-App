import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ locals }) => {
	return {
		profile: locals.profile,
		session: locals.session,
		demoMode: locals.demoMode,
		demoPersona: locals.demoPersona
	};
};
