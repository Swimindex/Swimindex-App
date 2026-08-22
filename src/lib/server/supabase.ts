import { createBrowserClient, createServerClient, type CookieOptions } from '@supabase/ssr';
import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import { PUBLIC_SUPABASE_ANON_KEY, PUBLIC_SUPABASE_URL } from '$env/static/public';
import type { Cookies } from '@sveltejs/kit';

export function createSupabaseBrowserClient(): SupabaseClient {
	return createBrowserClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY);
}

export function createSupabaseServerClient(cookies: Cookies): SupabaseClient {
	return createServerClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY, {
		cookies: {
			getAll: () => cookies.getAll(),
			setAll: (cookiesToSet: { name: string; value: string; options: CookieOptions }[]) => {
				for (const { name, value, options } of cookiesToSet) {
					cookies.set(name, value, { ...options, path: '/' });
				}
			}
		}
	});
}

/** Service-role client for Edge-style server jobs. Never expose to browser. */
export function createSupabaseServiceClient(): SupabaseClient | null {
	const url = PUBLIC_SUPABASE_URL;
	const key = (typeof process !== 'undefined' && process.env?.SUPABASE_SERVICE_ROLE_KEY) || '';
	if (!url || !key) return null;
	return createClient(url, key, { auth: { persistSession: false } });
}

export function supabaseConfigured(): boolean {
	return Boolean(PUBLIC_SUPABASE_URL && PUBLIC_SUPABASE_ANON_KEY);
}
