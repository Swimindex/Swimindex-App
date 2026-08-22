/**
 * Demo / fallback data used when Supabase is not configured.
 * Clearly sample — not live rankings.
 */

import type { EventCatalogRow, Profile, StandardMet } from '$lib/types/swim';

export const DEMO_EVENTS: EventCatalogRow[] = [
	{ id: 'e-50fr-scy', stroke: 'free', distance_m: 50, course: 'SCY', is_relay: false, label: '50 Free SCY' },
	{ id: 'e-100fr-scy', stroke: 'free', distance_m: 100, course: 'SCY', is_relay: false, label: '100 Free SCY' },
	{ id: 'e-200fr-scy', stroke: 'free', distance_m: 200, course: 'SCY', is_relay: false, label: '200 Free SCY' },
	{ id: 'e-100bk-scy', stroke: 'back', distance_m: 100, course: 'SCY', is_relay: false, label: '100 Back SCY' },
	{ id: 'e-100br-scy', stroke: 'breast', distance_m: 100, course: 'SCY', is_relay: false, label: '100 Breast SCY' },
	{ id: 'e-100fl-scy', stroke: 'fly', distance_m: 100, course: 'SCY', is_relay: false, label: '100 Fly SCY' },
	{ id: 'e-200im-scy', stroke: 'im', distance_m: 200, course: 'SCY', is_relay: false, label: '200 IM SCY' },
	{ id: 'e-100fr-lcm', stroke: 'free', distance_m: 100, course: 'LCM', is_relay: false, label: '100 Free LCM' },
	{ id: 'e-200fr-relay', stroke: 'free', distance_m: 200, course: 'SCY', is_relay: true, label: '200 Free Relay SCY' }
];

export const DEMO_RANKINGS = [
	{
		rank: 1,
		username: 'maya.chen',
		display_name: 'Maya Chen',
		club_name: 'Pacific Tide',
		region: 'CA',
		seasonal_age: 16,
		open_index: 912.4,
		age_adjusted_index: 1048.2,
		course: 'SCY' as const,
		top_event: '100 Free SCY'
	},
	{
		rank: 2,
		username: 'jordan.lee',
		display_name: 'Jordan Lee',
		club_name: 'Metro Aquatics',
		region: 'NY',
		seasonal_age: 17,
		open_index: 898.1,
		age_adjusted_index: 1012.6,
		course: 'SCY' as const,
		top_event: '200 IM SCY'
	},
	{
		rank: 3,
		username: 'sam.okada',
		display_name: 'Sam Okada',
		club_name: 'Lakeview Swim Club',
		region: 'WA',
		seasonal_age: 15,
		open_index: 871.5,
		age_adjusted_index: 1095.0,
		course: 'LCM' as const,
		top_event: '100 Free LCM'
	}
];

export const DEMO_PROFILE: Profile = {
	id: 'demo-maya',
	username: 'maya.chen',
	display_name: 'Maya Chen',
	role: 'swimmer',
	gender: 'F',
	date_of_birth: '2009-03-14',
	region: 'CA',
	club_name: 'Pacific Tide',
	seasonal_age: 16,
	age_group_label: '15-16',
	bio: 'Sprint freestyle & fly. Demo profile.'
};

export const DEMO_PBS = [
	{
		event: '50 Free SCY',
		course: 'SCY' as const,
		time_ms: 23250,
		achieved_on: '2025-11-08',
		open_index: 940.2
	},
	{
		event: '100 Free SCY',
		course: 'SCY' as const,
		time_ms: 51200,
		achieved_on: '2026-01-18',
		open_index: 912.4
	},
	{
		event: '100 Fly SCY',
		course: 'SCY' as const,
		time_ms: 55800,
		achieved_on: '2025-12-02',
		open_index: 880.1
	},
	{
		event: '100 Free LCM',
		course: 'LCM' as const,
		time_ms: 57200,
		achieved_on: '2025-07-22',
		open_index: 845.0
	}
];

export const DEMO_STANDARDS_MET: StandardMet[] = [
	{
		label: 'Meets D1 B-cut: 100 Free',
		tier: 'D1_B',
		event: '100 Free SCY',
		cut_time_ms: 50500,
		pb_time_ms: 51200
	},
	{
		label: 'Meets D1 B-cut: 50 Free',
		tier: 'D1_B',
		event: '50 Free SCY',
		cut_time_ms: 23200,
		pb_time_ms: 23250
	}
];

export const DEMO_PENDING = [
	{
		id: 'p1',
		swimmer: 'Jordan Lee',
		event: '100 Back SCY',
		time_ms: 54800,
		meet: 'Winter Invite',
		meet_level: 'invitational',
		dq: false,
		dq_reason: null as null,
		splits: [27200, 27600],
		competition_date: '2026-02-01'
	},
	{
		id: 'p2',
		swimmer: 'Sam Okada',
		event: '200 Free SCY',
		time_ms: 108500,
		meet: 'Dual vs Eastside',
		meet_level: 'dual',
		dq: true,
		dq_reason: 'false_start' as const,
		splits: null as number[] | null,
		competition_date: '2026-01-28'
	}
];
