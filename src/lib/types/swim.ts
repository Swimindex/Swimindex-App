export type UserRole = 'swimmer' | 'coach' | 'admin';
export type Stroke = 'free' | 'back' | 'breast' | 'fly' | 'im';
export type Course = 'SCY' | 'SCM' | 'LCM';
export type Gender = 'M' | 'F' | 'X';
export type MeetLevel =
	| 'dual'
	| 'invitational'
	| 'sectional'
	| 'state'
	| 'national'
	| 'international'
	| 'olympic_trials';
export type RaceRound = 'prelim' | 'final' | 'timed_final';
export type DqReason =
	| 'false_start'
	| 'stroke_infraction'
	| 'illegal_turn'
	| 'illegal_finish'
	| 'other';
export type VerificationStatus = 'pending' | 'verified' | 'rejected';
export type NcaaTier = 'D1_A' | 'D1_B' | 'D2' | 'D3' | 'NAIA' | 'JUCO';
export type IndexMode = 'open' | 'age_adjusted';

export type Profile = {
	id: string;
	username: string;
	display_name: string;
	role: UserRole;
	gender: Gender | null;
	date_of_birth: string | null;
	region: string | null;
	club_name: string | null;
	seasonal_age: number | null;
	age_group_label: string | null;
	bio: string | null;
};

export type EventCatalogRow = {
	id: string;
	stroke: Stroke;
	distance_m: number;
	course: Course;
	is_relay: boolean;
	label: string;
};

export type Performance = {
	id: string;
	swimmer_id: string;
	race_id: string;
	event_catalog_id: string;
	time_ms: number;
	seed_time_ms: number | null;
	reaction_time_ms: number | null;
	splits: number[] | null;
	dq: boolean;
	dq_reason: DqReason | null;
	meet_level: MeetLevel;
	course: Course;
	competition_date: string;
	seasonal_age_at_meet: number | null;
	is_relay: boolean;
	relay_leg_position: number | null;
	verification_status: VerificationStatus;
	is_personal_best: boolean;
	open_event_index: number | null;
	age_adjusted_event_index: number | null;
};

export type SwimmerIndex = {
	swimmer_id: string;
	open_index: number | null;
	age_adjusted_index: number | null;
	events_counted: number;
	last_computed_at: string | null;
};

export type PersonalBest = {
	id: string;
	swimmer_id: string;
	event_catalog_id: string;
	performance_id: string;
	time_ms: number;
	course: Course;
	achieved_on: string;
	events_catalog?: EventCatalogRow;
};

export type StandardMet = {
	label: string;
	tier: NcaaTier;
	event: string;
	cut_time_ms: number;
	pb_time_ms: number;
};

export const STROKE_LABELS: Record<Stroke, string> = {
	free: 'Free',
	back: 'Back',
	breast: 'Breast',
	fly: 'Fly',
	im: 'IM'
};

export const COURSE_LABELS: Record<Course, string> = {
	SCY: 'SCY — Short Course Yards',
	SCM: 'SCM — Short Course Meters',
	LCM: 'LCM — Long Course Meters'
};

export const MEET_LEVEL_LABELS: Record<MeetLevel, string> = {
	dual: 'Dual',
	invitational: 'Invitational',
	sectional: 'Sectional',
	state: 'State',
	national: 'National',
	international: 'International',
	olympic_trials: 'Olympic Trials'
};

export const DQ_REASON_LABELS: Record<DqReason, string> = {
	false_start: 'False start',
	stroke_infraction: 'Stroke infraction',
	illegal_turn: 'Illegal turn',
	illegal_finish: 'Illegal finish',
	other: 'Other'
};

export const DEFAULT_MEET_WEIGHTS: Record<MeetLevel, number> = {
	dual: 0.7,
	invitational: 0.85,
	sectional: 1.0,
	state: 1.1,
	national: 1.25,
	international: 1.35,
	olympic_trials: 1.5
};
