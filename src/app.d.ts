import type { Profile } from '$lib/types/swim';
import type { Session, SupabaseClient, User } from '@supabase/supabase-js';

declare global {
	namespace App {
		interface Locals {
			supabase: SupabaseClient | null;
			session: Session | null;
			user: User | null;
			profile: Profile | null;
		}
		interface Platform {
			env: {
				PUBLIC_SUPABASE_URL?: string;
				PUBLIC_SUPABASE_ANON_KEY?: string;
				SUPABASE_SERVICE_ROLE_KEY?: string;
			};
			context: {
				waitUntil(promise: Promise<unknown>): void;
			};
			caches: CacheStorage & { default: Cache };
		}
	}
}

export {};
