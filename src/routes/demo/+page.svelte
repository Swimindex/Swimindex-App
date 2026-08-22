<script lang="ts">
	import { DEMO_PERSONAS } from '$lib/demo/mode';
	import { enhance } from '$app/forms';
</script>

<svelte:head><title>Demo walkthrough · SwimIndex</title></svelte:head>

<div class="mx-auto max-w-3xl space-y-8">
	<header>
		<p class="text-xs font-semibold uppercase tracking-wider text-amber-800">Client demo</p>
		<h1 class="mt-1 text-3xl font-semibold text-teal-950">Walk the product without a backend</h1>
		<p class="mt-2 text-sm text-slate-600">
			Sample data only. Pick a persona to explore rankings, profiles, coach verification, and admin
			reference tables.
		</p>
	</header>

	<div class="grid gap-4 sm:grid-cols-3">
		{#each DEMO_PERSONAS as p}
			<form method="POST" action="?/persona" use:enhance class="contents">
				<button
					type="submit"
					name="persona"
					value={p.id}
					class="rounded-xl border border-slate-200 bg-white/90 p-5 text-left shadow-sm transition hover:border-teal-400 hover:shadow-md"
				>
					<p class="text-lg font-semibold text-teal-950">{p.label}</p>
					<p class="mt-2 text-sm text-slate-600">{p.blurb}</p>
					<p class="mt-4 text-xs font-medium text-teal-700">Enter →</p>
				</button>
			</form>
		{/each}
	</div>

	<section class="rounded-xl border border-slate-200 bg-white/80 p-5 text-sm text-slate-700">
		<h2 class="font-semibold text-teal-950">Suggested pitch path</h2>
		<ol class="mt-3 list-decimal space-y-2 pl-5">
			<li><a class="text-teal-800 underline" href="/rankings">Rankings</a> — open vs age-adjusted, course filters</li>
			<li><a class="text-teal-800 underline" href="/profile/maya.chen">Swimmer profile</a> — PBs first, index second</li>
			<li><a class="text-teal-800 underline" href="/scholarships/maya.chen">Scholarships</a> — recruiting cut badges</li>
			<li>Switch to <strong>Coach</strong> → Verify (DQ + split sanity)</li>
			<li>Switch to <strong>Admin</strong> → reference standards & scheduled jobs</li>
		</ol>
	</section>
</div>
