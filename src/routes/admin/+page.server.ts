import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
	const isAdmin = locals.profile?.role === 'admin';

	const tables = [
		{
			key: 'events_catalog',
			label: 'Events catalog',
			hint: 'Legal stroke × distance × course combos',
			count: 68
		},
		{
			key: 'standard_times',
			label: 'Open standard times',
			hint: 'Elite / WA-style base times',
			count: 102
		},
		{
			key: 'age_group_standard_times',
			label: 'Age-group standards',
			hint: 'Motivational / AG reference times',
			count: 48
		},
		{
			key: 'course_conversion_factors',
			label: 'Course conversions',
			hint: 'Estimated equivalents only — never overwrite',
			count: 24
		},
		{
			key: 'recruiting_standards',
			label: 'Recruiting standards',
			hint: 'Sample NCAA cuts — update yearly',
			count: 24
		}
	];

	if (locals.supabase && isAdmin) {
		for (const t of tables) {
			const { count } = await locals.supabase
				.from(t.key)
				.select('*', { count: 'exact', head: true });
			if (count != null) t.count = count;
		}
	}

	return { isAdmin, tables };
};
