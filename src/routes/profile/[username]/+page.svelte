<script lang="ts">
	import AgeGroupToggle from '$lib/components/AgeGroupToggle.svelte';
	import CourseTag from '$lib/components/CourseTag.svelte';
	import { formatSwimTime } from '$lib/swim/time';
	import type { IndexMode } from '$lib/types/swim';
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();
	let mode = $state<IndexMode>('open');

	const byCourse = $derived(
		(['SCY', 'SCM', 'LCM'] as const).map((c) => ({
			course: c,
			rows: data.pbs.filter((p) => p.course === c)
		})).filter((g) => g.rows.length > 0)
	);
</script>

<svelte:head>
	<title>{data.profile.display_name} · SwimIndex</title>
</svelte:head>

<div class="space-y-8">
	<header class="flex flex-wrap items-start justify-between gap-4">
		<div>
			<h1 class="text-3xl font-semibold text-teal-950">{data.profile.display_name}</h1>
			<p class="mt-1 text-slate-600">
				@{data.profile.username}
				{#if data.profile.club_name}· {data.profile.club_name}{/if}
				{#if data.profile.region}· {data.profile.region}{/if}
			</p>
			<p class="mt-2 text-sm text-slate-500">
				Seasonal age {data.profile.seasonal_age ?? '—'}
				{#if data.profile.age_group_label}({data.profile.age_group_label}){/if}
			</p>
		</div>
		<div class="rounded-xl border border-slate-200 bg-white/80 p-4 text-right shadow-sm">
			<AgeGroupToggle bind:value={mode} />
			<p class="mt-3 font-mono text-3xl font-semibold tabular-nums text-teal-950">
				{mode === 'open'
					? (data.open_index?.toFixed(1) ?? '—')
					: (data.age_adjusted_index?.toFixed(1) ?? '—')}
			</p>
			<p class="text-xs text-slate-500">Composite index (secondary to PBs)</p>
		</div>
	</header>

	<section>
		<h2 class="text-xl font-semibold text-teal-950">Personal Bests</h2>
		<p class="mt-1 text-sm text-slate-600">Grouped by course — never blended.</p>

		{#each byCourse as group}
			<div class="mt-6">
				<div class="mb-2 flex items-center gap-2">
					<CourseTag course={group.course} />
					<span class="text-sm font-medium text-slate-700">{group.course} bests</span>
				</div>
				<div class="overflow-x-auto rounded-xl border border-slate-200 bg-white/80">
					<table class="min-w-full text-sm">
						<thead class="border-b border-slate-200 bg-slate-50 text-xs uppercase text-slate-500">
							<tr>
								<th class="px-4 py-2 text-left">Event</th>
								<th class="px-4 py-2 text-left">Time</th>
								<th class="px-4 py-2 text-left">Date</th>
								<th class="px-4 py-2 text-left">Open pts</th>
							</tr>
						</thead>
						<tbody>
							{#each group.rows as pb}
								<tr class="border-b border-slate-100">
									<td class="px-4 py-2 font-medium">{pb.event}</td>
									<td class="px-4 py-2 font-mono tabular-nums">{formatSwimTime(pb.time_ms)}</td>
									<td class="px-4 py-2 text-slate-600">{pb.achieved_on}</td>
									<td class="px-4 py-2 font-mono text-slate-600"
										>{pb.open_index?.toFixed(1) ?? '—'}</td
									>
								</tr>
							{/each}
						</tbody>
					</table>
				</div>
			</div>
		{/each}
	</section>

	<p class="text-sm">
		<a class="text-teal-800 underline" href="/scholarships/{data.profile.username}"
			>Scholarship / recruiting profile →</a
		>
	</p>
</div>
