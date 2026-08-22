import { z } from 'zod';

export const strokeSchema = z.enum(['free', 'back', 'breast', 'fly', 'im']);
export const courseSchema = z.enum(['SCY', 'SCM', 'LCM']);
export const meetLevelSchema = z.enum([
	'dual',
	'invitational',
	'sectional',
	'state',
	'national',
	'international',
	'olympic_trials'
]);
export const dqReasonSchema = z.enum([
	'false_start',
	'stroke_infraction',
	'illegal_turn',
	'illegal_finish',
	'other'
]);

export const performanceSubmitSchema = z
	.object({
		event_catalog_id: z.string().uuid(),
		competition_name: z.string().min(2).max(200),
		meet_level: meetLevelSchema,
		course: courseSchema,
		competition_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
		time_ms: z.number().int().positive(),
		seed_time_ms: z.number().int().positive().nullable().optional(),
		reaction_time_ms: z.number().int().nonnegative().nullable().optional(),
		splits: z.array(z.number().int().positive()).nullable().optional(),
		dq: z.boolean().default(false),
		dq_reason: dqReasonSchema.nullable().optional(),
		is_relay: z.boolean().default(false),
		relay_leg_position: z.number().int().min(1).max(4).nullable().optional(),
		round: z.enum(['prelim', 'final', 'timed_final']).default('timed_final')
	})
	.superRefine((data, ctx) => {
		if (data.dq && !data.dq_reason) {
			ctx.addIssue({
				code: 'custom',
				message: 'DQ reason required when DQ is set',
				path: ['dq_reason']
			});
		}
		if (data.is_relay && data.relay_leg_position == null) {
			ctx.addIssue({
				code: 'custom',
				message: 'Relay leg position (1–4) required for relays',
				path: ['relay_leg_position']
			});
		}
	});

export const signupSchema = z.object({
	email: z.string().email(),
	username: z
		.string()
		.min(3)
		.max(32)
		.regex(/^[a-z0-9_]+$/),
	display_name: z.string().min(1).max(80),
	role: z.enum(['swimmer', 'coach']).default('swimmer'),
	gender: z.enum(['M', 'F', 'X']).optional(),
	date_of_birth: z
		.string()
		.regex(/^\d{4}-\d{2}-\d{2}$/)
		.optional()
});
