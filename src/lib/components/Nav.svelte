<script lang="ts">
	import { DEMO_PERSONAS, type DemoPersona } from '$lib/demo/mode';
	import type { Profile } from '$lib/types/swim';
	import { enhance } from '$app/forms';

	interface Props {
		profile?: Profile | null;
		demoMode?: boolean;
		demoPersona?: DemoPersona | null;
	}

	let { profile = null, demoMode = false, demoPersona = null }: Props = $props();
</script>

<header class="border-b border-white/10 bg-[#043d4a] text-white">
	<div class="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-3 px-4 py-4">
		<a href="/" class="group flex items-baseline gap-2">
			<span class="brand text-2xl tracking-tight transition group-hover:text-teal-200">SwimIndex</span
			>
			<span class="hidden text-xs text-teal-200/70 sm:inline">clock-based rankings</span>
		</a>

		<nav class="flex flex-wrap items-center gap-1 text-sm sm:gap-2">
			<a class="rounded-md px-2 py-1 hover:bg-white/10" href="/rankings">Rankings</a>
			{#if profile}
				<a class="rounded-md px-2 py-1 hover:bg-white/10" href="/submit">Submit</a>
				<a class="rounded-md px-2 py-1 hover:bg-white/10" href="/profile/{profile.username}"
					>Profile</a
				>
				<a class="rounded-md px-2 py-1 hover:bg-white/10" href="/scholarships/{profile.username}"
					>Scholarships</a
				>
				{#if profile.role === 'coach' || profile.role === 'admin'}
					<a class="rounded-md px-2 py-1 hover:bg-white/10" href="/verify">Verify</a>
				{/if}
				{#if profile.role === 'admin'}
					<a class="rounded-md px-2 py-1 hover:bg-white/10" href="/admin">Admin</a>
				{/if}
			{:else}
				<a class="rounded-md px-2 py-1 hover:bg-white/10" href="/login">Log in</a>
				<a
					class="rounded-md bg-teal-400 px-3 py-1.5 font-medium text-teal-950 hover:bg-teal-300"
					href="/signup">Join</a
				>
			{/if}
		</nav>
	</div>

	{#if demoMode}
		<div class="border-t border-white/10 bg-[#032f39] px-4 py-2">
			<form
				method="POST"
				action="/demo?/persona"
				class="mx-auto flex max-w-6xl flex-wrap items-center gap-2 text-xs sm:text-sm"
				use:enhance
			>
				<span class="mr-1 text-teal-200/80">View as</span>
				{#each DEMO_PERSONAS as p}
					<button
						type="submit"
						name="persona"
						value={p.id}
						class="rounded-md px-2.5 py-1 transition
						{demoPersona === p.id
							? 'bg-teal-300 font-semibold text-teal-950'
							: 'bg-white/10 text-white hover:bg-white/20'}"
					>
						{p.label}
					</button>
				{/each}
				<span class="ml-auto hidden text-teal-200/60 md:inline">
					{DEMO_PERSONAS.find((p) => p.id === demoPersona)?.blurb}
				</span>
			</form>
		</div>
	{/if}
</header>
