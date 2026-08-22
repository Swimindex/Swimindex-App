import { env } from '$env/dynamic/public';
import { createServerClient } from '@supabase/ssr';
import {
	DEMO_PERSONA_COOKIE,
	isDemoMode,
	personaFromCookie,
	profileForPersona
} from '$lib/demo/mode';
import type { Handle } from '@sveltejs/kit';

export const handle: Handle = async ({ event, resolve }) => {
	const demo = isDemoMode(env.PUBLIC_DEMO_MODE, env.PUBLIC_SUPABASE_URL);
	event.locals.demoMode = demo;

	if (demo) {
		const persona = personaFromCookie(event.cookies.get(DEMO_PERSONA_COOKIE));
		event.locals.demoPersona = persona;
		event.locals.supabase = null;
		event.locals.session = null;
		event.locals.user = null;
		event.locals.profile = profileForPersona(persona);

		return resolve(event, {
			filterSerializedResponseHeaders(name) {
				return name === 'content-range' || name === 'x-supabase-api-version';
			}
		});
	}

	event.locals.demoPersona = null;
	const url = env.PUBLIC_SUPABASE_URL || '';
	const key = env.PUBLIC_SUPABASE_ANON_KEY || '';

	if (url && key) {
		event.locals.supabase = createServerClient(url, key, {
			cookies: {
				getAll: () => event.cookies.getAll(),
				setAll: (cookiesToSet) => {
					for (const { name, value, options } of cookiesToSet) {
						event.cookies.set(name, value, { ...options, path: '/' });
					}
				}
			}
		});

		const {
			data: { session }
		} = await event.locals.supabase.auth.getSession();
		event.locals.session = session;
		event.locals.user = session?.user ?? null;

		if (session?.user) {
			const { data: profile } = await event.locals.supabase
				.from('profiles')
				.select('*')
				.eq('id', session.user.id)
				.maybeSingle();
			event.locals.profile = profile;
		} else {
			event.locals.profile = null;
		}
	} else {
		event.locals.supabase = null;
		event.locals.session = null;
		event.locals.user = null;
		event.locals.profile = null;
	}

	return resolve(event, {
		filterSerializedResponseHeaders(name) {
			return name === 'content-range' || name === 'x-supabase-api-version';
		}
	});
};
