<script lang="ts">
	import { formatSwimTime } from '$lib/swim/time';
	import { pacingProfile, type PaceProfile } from '$lib/swim/splits';

	interface Props {
		splits: number[];
	}

	let { splits }: Props = $props();
	let max = $derived(Math.max(...splits, 1));
	let profile = $derived(pacingProfile(splits));

	const labels: Record<PaceProfile, string> = {
		even: 'Even split',
		negative: 'Negative split',
		positive: 'Positive split',
		unknown: '—'
	};
</script>

{#if splits.length > 0}
	<div class="space-y-3">
		<div class="flex items-center justify-between">
			<h3 class="text-sm font-semibold text-slate-800">Pacing</h3>
			<span
				class="rounded-md px-2 py-0.5 text-xs font-medium
				{profile === 'negative'
					? 'bg-teal-100 text-teal-900'
					: profile === 'positive'
						? 'bg-amber-100 text-amber-900'
						: 'bg-slate-100 text-slate-700'}"
			>
				{labels[profile]}
			</span>
		</div>
		<div class="flex h-28 items-end gap-1.5" role="img" aria-label="Split pacing chart">
			{#each splits as split, i}
				<div class="flex flex-1 flex-col items-center gap-1">
					<span class="font-mono text-[0.65rem] text-slate-500">{formatSwimTime(split)}</span>
					<div
						class="w-full rounded-t-md bg-gradient-to-t from-teal-700 to-teal-400 transition-all duration-500"
						style="height: {(split / max) * 100}%"
						title="Split {i + 1}: {formatSwimTime(split)}"
					></div>
					<span class="text-[0.65rem] text-slate-400">{i + 1}</span>
				</div>
			{/each}
		</div>
	</div>
{/if}
