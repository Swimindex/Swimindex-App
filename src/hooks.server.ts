import { PUBLIC_SUPABASE_ANON_KEY, PUBLIC_SUPABASE_URL } from '$env/static/public';
import { createServerClient } from '@supabase/ssr';
import type { Handle } from '@sveltejs/kit';

export const handle: Handle = async ({ event, resolve }) => {
	const url = PUBLIC_SUPABASE_URL || '';
	const key = PUBLIC_SUPABASE_ANON_KEY || '';

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
