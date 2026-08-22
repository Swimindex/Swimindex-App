<script lang="ts">
	import '../app.css';
	import Nav from '$lib/components/Nav.svelte';
	import type { LayoutData } from './$types';

	let { data, children }: { data: LayoutData; children: import('svelte').Snippet } = $props();
</script>

<div class="min-h-screen bg-[radial-gradient(ellipse_at_top,_#e6f4f1_0%,_#f8fafc_45%,_#eef2ff_100%)] text-slate-900">
	<Nav profile={data.profile} />
	<main class="mx-auto max-w-6xl px-4 py-8">
		{@render children()}
	</main>
	<footer class="mx-auto max-w-6xl px-4 py-10 text-xs text-slate-500">
		<p>
			SwimIndex — clock-based rankings. Indices mirror World Aquatics points-table math. Course
			conversions are estimates only.
		</p>
	</footer>
</div>
