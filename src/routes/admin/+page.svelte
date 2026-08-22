<script lang="ts">
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();
</script>

<svelte:head><title>Admin · SwimIndex</title></svelte:head>

<div class="space-y-8">
	<header>
		<h1 class="text-3xl font-semibold text-teal-950">Admin reference data</h1>
		<p class="mt-1 text-sm text-slate-600">
			Seed / reference tables. Standards and cuts change yearly — update here, don’t hardcode in app
			logic.
		</p>
	</header>

	{#if data.demoMode}
		<p class="rounded-lg bg-amber-50 px-4 py-3 text-sm text-amber-950">
			Demo admin — sample table counts and scheduled-job list for client walkthroughs.
		</p>
	{:else if !data.isAdmin}
		<p class="rounded-lg bg-amber-50 px-4 py-3 text-sm text-amber-950">
			Admin role required for edits.
		</p>
	{/if}

	<div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
		{#each data.tables as t}
			<article class="rounded-xl border border-slate-200 bg-white/80 p-5 shadow-sm">
				<h2 class="font-semibold text-teal-950">{t.label}</h2>
				<p class="mt-1 font-mono text-3xl tabular-nums text-slate-800">{t.count}</p>
				<p class="mt-2 text-xs text-slate-500">{t.hint}</p>
			</article>
		{/each}
	</div>

	<section class="rounded-xl border border-slate-200 bg-white/80 p-5 text-sm text-slate-700">
		<h2 class="font-semibold text-teal-950">Scheduled jobs</h2>
		<ul class="mt-3 list-inside list-disc space-y-1">
			<li>
				<code>recompute-indices</code> — nightly Edge Function recomputes open & age-adjusted
				composites
			</li>
			<li>
				<code>age-group-aging-up</code> — season boundary (default Sep 1) refreshes seasonal ages
				then recomputes indices
			</li>
		</ul>
	</section>
</div>
