<script lang="ts">
	import { fade, fly } from 'svelte/transition';
</script>

<svelte:head>
	<title>SwimIndex — Clock-based swim rankings</title>
	<meta
		name="description"
		content="Open and age-adjusted swim indices from verified meet times. Personal bests first, World Aquatics–style points second."
	/>
</svelte:head>

<section class="relative overflow-hidden rounded-3xl border border-teal-900/10 bg-[#043d4a] text-white shadow-xl">
	<div
		class="pointer-events-none absolute inset-0 opacity-40"
		style="background:
			radial-gradient(circle at 20% 20%, rgba(45,212,191,0.35), transparent 40%),
			radial-gradient(circle at 80% 0%, rgba(56,189,248,0.25), transparent 35%),
			repeating-linear-gradient(90deg, transparent, transparent 48px, rgba(255,255,255,0.04) 48px, rgba(255,255,255,0.04) 50px);"
	></div>

	<div class="relative grid gap-10 px-6 py-16 md:grid-cols-[1.2fr_0.8fr] md:px-12 md:py-24">
		<div in:fly={{ y: 16, duration: 500 }}>
			<p class="brand text-5xl tracking-tight md:text-6xl">SwimIndex</p>
			<h1 class="mt-4 max-w-xl text-2xl font-medium text-teal-50 md:text-3xl">
				Rankings from the clock — not the opponent.
			</h1>
			<p class="mt-4 max-w-lg text-base text-teal-100/85">
				Verified meet times scored with World Aquatics–style points, plus a fair age-adjusted
				index for developing swimmers. Personal bests stay course-specific.
			</p>
			<div class="mt-8 flex flex-wrap gap-3">
				<a
					href="/rankings"
					class="rounded-lg bg-teal-300 px-5 py-2.5 font-semibold text-teal-950 transition hover:bg-teal-200"
					>View rankings</a
				>
				<a
					href="/signup"
					class="rounded-lg border border-white/30 px-5 py-2.5 font-medium text-white transition hover:bg-white/10"
					>Create profile</a
				>
			</div>
		</div>

		<aside
			class="flex flex-col justify-end gap-4 rounded-2xl border border-white/10 bg-white/5 p-6 backdrop-blur-sm"
			in:fade={{ duration: 700, delay: 120 }}
		>
			<div>
				<p class="text-xs uppercase tracking-wider text-teal-200/70">Open Index</p>
				<p class="font-mono text-4xl font-semibold tabular-nums">1000 × (std / time)³</p>
			</div>
			<div class="grid grid-cols-3 gap-3 text-center text-sm">
				<div class="rounded-lg bg-black/20 p-3">
					<p class="text-teal-200/70">SCY</p>
					<p class="font-semibold">Yards</p>
				</div>
				<div class="rounded-lg bg-black/20 p-3">
					<p class="text-teal-200/70">SCM</p>
					<p class="font-semibold">Meters</p>
				</div>
				<div class="rounded-lg bg-black/20 p-3">
					<p class="text-teal-200/70">LCM</p>
					<p class="font-semibold">Long</p>
				</div>
			</div>
			<p class="text-xs text-teal-100/60">
				Courses never silently blend. Converted times are labeled estimates only.
			</p>
		</aside>
	</div>
</section>

<section class="mt-16 grid gap-10 md:grid-cols-3">
	{#each [
		{
			title: 'Canonical events',
			body: 'Stroke × distance × course from a legal catalog — no invented 50 IM or 1500 back.'
		},
		{
			title: 'Two indices',
			body: 'Open Index vs age-group standards. Seasonal age (Sep 1) buckets developing athletes fairly.'
		},
		{
			title: 'Coach verification',
			body: 'DQ flags and split-sum checks before a swim can enter the index or PBs.'
		}
	] as card, i}
		<article
			class="border-t border-teal-800/20 pt-4"
			in:fly={{ y: 12, delay: 80 * i, duration: 400 }}
		>
			<h2 class="text-lg font-semibold text-teal-950">{card.title}</h2>
			<p class="mt-2 text-sm text-slate-600">{card.body}</p>
		</article>
	{/each}
</section>
