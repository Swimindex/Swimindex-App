<script lang="ts">
	import RecruitingStandardBadge from '$lib/components/RecruitingStandardBadge.svelte';
	import { formatSwimTime } from '$lib/swim/time';
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();
</script>

<svelte:head>
	<title>Scholarships · {data.profile.display_name}</title>
</svelte:head>

<div class="space-y-8">
	<header>
		<p class="text-xs font-semibold uppercase tracking-wider text-amber-800">Recruiting</p>
		<h1 class="mt-1 text-3xl font-semibold text-teal-950">{data.profile.display_name}</h1>
		<p class="mt-2 text-sm text-slate-600">
			Standards met are derived from verified PBs vs sample recruiting cuts (seed data — update
			yearly).
		</p>
	</header>

	<section class="flex flex-wrap gap-2">
		{#each data.standards as s}
			<RecruitingStandardBadge label={s.label} tier={s.tier.replace('_', ' ')} />
		{:else}
			<p class="text-sm text-slate-500">No recruiting standards met yet.</p>
		{/each}
	</section>

	<section class="overflow-x-auto rounded-xl border border-slate-200 bg-white/80">
		<table class="min-w-full text-sm">
			<thead class="border-b bg-slate-50 text-xs uppercase text-slate-500">
				<tr>
					<th class="px-4 py-2 text-left">Standard</th>
					<th class="px-4 py-2 text-left">Event</th>
					<th class="px-4 py-2 text-left">Cut</th>
					<th class="px-4 py-2 text-left">PB</th>
				</tr>
			</thead>
			<tbody>
				{#each data.standards as s}
					<tr class="border-b border-slate-100">
						<td class="px-4 py-2 font-medium">{s.label}</td>
						<td class="px-4 py-2">{s.event}</td>
						<td class="px-4 py-2 font-mono">{formatSwimTime(s.cut_time_ms)}</td>
						<td class="px-4 py-2 font-mono">{formatSwimTime(s.pb_time_ms)}</td>
					</tr>
				{/each}
			</tbody>
		</table>
	</section>
</div>
