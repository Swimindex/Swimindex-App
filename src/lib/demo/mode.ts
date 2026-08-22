/**
 * Demo mode helpers — client pitches without a live backend.
 * Enable with PUBLIC_DEMO_MODE=true (also auto-on when Supabase is unset/placeholder).
 */

import { DEMO_PROFILE } from '$lib/demo/data';
import type { Profile, UserRole } from '$lib/types/swim';

export const DEMO_PERSONA_COOKIE = 'swimindex_demo_persona';

export type DemoPersona = 'swimmer' | 'coach' | 'admin';

export const DEMO_PERSONAS: {
	id: DemoPersona;
	label: string;
	blurb: string;
	profile: Profile;
}[] = [
	{
		id: 'swimmer',
		label: 'Swimmer',
		blurb: 'Profile, PBs, scholarships, submit a swim',
		profile: {
			...DEMO_PROFILE,
			id: 'demo-swimmer',
			role: 'swimmer',
			username: 'maya.chen',
			display_name: 'Maya Chen'
		}
	},
	{
		id: 'coach',
		label: 'Coach',
		blurb: 'Verify queue with DQ + split checks',
		profile: {
			...DEMO_PROFILE,
			id: 'demo-coach',
			role: 'coach',
			username: 'coach.rivera',
			display_name: 'Alex Rivera',
			club_name: 'Pacific Tide',
			bio: 'Head coach — demo persona.',
			seasonal_age: null,
			age_group_label: null,
			date_of_birth: null,
			gender: 'X'
		}
	},
	{
		id: 'admin',
		label: 'Admin',
		blurb: 'Reference tables & scheduled jobs',
		profile: {
			...DEMO_PROFILE,
			id: 'demo-admin',
			role: 'admin',
			username: 'admin',
			display_name: 'Site Admin',
			club_name: 'SwimIndex',
			bio: 'Admin persona for demos.',
			seasonal_age: null,
			age_group_label: null,
			date_of_birth: null,
			gender: 'X'
		}
	}
];

export function isDemoMode(publicDemoFlag?: string, supabaseUrl?: string): boolean {
	if (publicDemoFlag === 'true' || publicDemoFlag === '1') return true;
	if (publicDemoFlag === 'false' || publicDemoFlag === '0') return false;
	if (!supabaseUrl) return true;
	if (
		supabaseUrl.includes('your-project') ||
		supabaseUrl.includes('placeholder') ||
		supabaseUrl.includes('example.supabase')
	) {
		return true;
	}
	return false;
}

export function personaFromCookie(value: string | undefined): DemoPersona {
	if (value === 'coach' || value === 'admin' || value === 'swimmer') return value;
	return 'admin';
}

export function profileForPersona(persona: DemoPersona): Profile {
	return DEMO_PERSONAS.find((p) => p.id === persona)?.profile ?? DEMO_PERSONAS[0].profile;
}

export function roleAllowsVerify(role: UserRole | null | undefined): boolean {
	return role === 'coach' || role === 'admin';
}
