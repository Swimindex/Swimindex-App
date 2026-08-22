<script lang="ts">
	import AgeGroupToggle from '$lib/components/AgeGroupToggle.svelte';
	import CourseTag from '$lib/components/CourseTag.svelte';
	import type { Course, IndexMode, MeetLevel } from '$lib/types/swim';
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();

	let mode = $state<IndexMode>('open');
	let course = $state<Course | 'all'>('all');
	let meetLevel = $state<MeetLevel | 'all'>('all');

	let rows = $derived(
		data.rankings.filter((r) => {
			if (course !== 'all' && r.course !== course) return false;
			if (meetLevel !== 'all' && r.meet_level && r.meet_level !== meetLevel) return false;
			return true;
		})
	);
</script>

<svelte:head>
	<title>Rankings · SwimIndex</title>
</svelte:head>

<div class="space-y-6">
	<header class="flex flex-wrap items-end justify-between gap-4">
		<div>
			<h1 class="text-3xl font-semibold text-teal-950">Rankings</h1>
			<p class="mt-1 text-sm text-slate-600">
				Course-specific. Toggle Open vs Age-Adjusted.
				{#if data.demoMode}
					<span class="text-amber-800">Showing sample rankings for the client demo.</span>
				{/if}
			</p>
		</div>
		<AgeGroupToggle bind:value={mode} />
	</header>

	<div class="flex flex-wrap gap-3 text-sm">
		<label class="flex items-center gap-2">
			<span class="text-slate-600">Course</span>
			<select class="rounded-md border border-slate-300 bg-white px-2 py-1.5" bind:value={course}>
				<option value="all">All</option>
				<option value="SCY">SCY</option>
				<option value="SCM">SCM</option>
				<option value="LCM">LCM</option>
			</select>
		</label>
		<label class="flex items-center gap-2">
			<span class="text-slate-600">Meet level</span>
			<select
				class="rounded-md border border-slate-300 bg-white px-2 py-1.5"
				bind:value={meetLevel}
			>
				<option value="all">All</option>
				<option value="dual">Dual</option>
				<option value="invitational">Invitational</option>
				<option value="sectional">Sectional</option>
				<option value="state">State</option>
				<option value="national">National</option>
				<option value="international">International</option>
				<option value="olympic_trials">Olympic Trials</option>
			</select>
		</label>
	</div>

	<div class="overflow-x-auto rounded-xl border border-slate-200 bg-white/80 shadow-sm">
		<table class="min-w-full text-left text-sm">
			<thead class="border-b border-slate-200 bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
				<tr>
					<th class="px-4 py-3">#</th>
					<th class="px-4 py-3">Swimmer</th>
					<th class="px-4 py-3">Age</th>
					<th class="px-4 py-3">Course</th>
					<th class="px-4 py-3">Index</th>
					<th class="px-4 py-3">Top event</th>
				</tr>
			</thead>
			<tbody>
				{#each rows as row, i}
					<tr class="border-b border-slate-100 hover:bg-teal-50/40">
						<td class="px-4 py-3 font-mono text-slate-500">{i + 1}</td>
						<td class="px-4 py-3">
							<a class="font-medium text-teal-900 hover:underline" href="/profile/{row.username}"
								>{row.display_name}</a
							>
							<p class="text-xs text-slate-500">{row.club_name} · {row.region}</p>
						</td>
						<td class="px-4 py-3">{row.seasonal_age}</td>
						<td class="px-4 py-3"><CourseTag course={row.course} /></td>
						<td class="px-4 py-3 font-mono font-semibold tabular-nums">
							{mode === 'open' ? row.open_index.toFixed(1) : row.age_adjusted_index.toFixed(1)}
						</td>
						<td class="px-4 py-3 text-slate-600">{row.top_event}</td>
					</tr>
				{/each}
			</tbody>
		</table>
	</div>
</div>
