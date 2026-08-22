<script lang="ts">
	import type { Profile } from '$lib/types/swim';

	interface Props {
		profile?: Profile | null;
	}

	let { profile = null }: Props = $props();
</script>

<header class="border-b border-white/10 bg-[#043d4a] text-white">
	<div class="mx-auto flex max-w-6xl items-center justify-between gap-4 px-4 py-4">
		<a href="/" class="group flex items-baseline gap-2">
			<span class="brand text-2xl tracking-tight transition group-hover:text-teal-200">SwimIndex</span>
			<span class="hidden text-xs text-teal-200/70 sm:inline">clock-based rankings</span>
		</a>

		<nav class="flex flex-wrap items-center gap-1 text-sm sm:gap-3">
			<a class="rounded-md px-2 py-1 hover:bg-white/10" href="/rankings">Rankings</a>
			{#if profile}
				<a class="rounded-md px-2 py-1 hover:bg-white/10" href="/submit">Submit</a>
				{#if profile.role === 'coach' || profile.role === 'admin'}
					<a class="rounded-md px-2 py-1 hover:bg-white/10" href="/verify">Verify</a>
				{/if}
				{#if profile.role === 'admin'}
					<a class="rounded-md px-2 py-1 hover:bg-white/10" href="/admin">Admin</a>
				{/if}
				<a class="rounded-md px-2 py-1 hover:bg-white/10" href="/profile/{profile.username}"
					>{profile.display_name}</a
				>
			{:else}
				<a class="rounded-md px-2 py-1 hover:bg-white/10" href="/login">Log in</a>
				<a
					class="rounded-md bg-teal-400 px-3 py-1.5 font-medium text-teal-950 hover:bg-teal-300"
					href="/signup">Join</a
				>
			{/if}
		</nav>
	</div>
</header>
