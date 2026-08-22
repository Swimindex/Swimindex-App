<script lang="ts">
	import { formatSwimTime, parseSwimTime } from '$lib/swim/time';
	import { expectedSplitCount, splitsMatchFinal } from '$lib/swim/splits';
	import type { Course } from '$lib/types/swim';

	interface Props {
		distanceM: number;
		course: Course;
		finalTimeMs: number | null;
		toleranceMs?: number;
		value?: number[] | null;
	}

	let {
		distanceM,
		course,
		finalTimeMs,
		toleranceMs = 100,
		value = $bindable(null)
	}: Props = $props();

	let count = $derived(expectedSplitCount(distanceM, course));
	let fields = $state<string[]>([]);

	$effect(() => {
		const n = count;
		if (fields.length !== n) {
			fields = Array.from({ length: n }, (_, i) =>
				value?.[i] != null ? formatSwimTime(value[i]) : ''
			);
		}
	});

	let parsed = $derived(fields.map((f) => (f.trim() ? parseSwimTime(f) : null)));
	let allParsed = $derived(parsed.every((p) => p != null) ? (parsed as number[]) : null);
	let check = $derived(
		allParsed && finalTimeMs ? splitsMatchFinal(allParsed, finalTimeMs, toleranceMs) : null
	);

	$effect(() => {
		value = allParsed;
	});

	let running = $derived(parsed.reduce<number>((acc, p) => acc + (p ?? 0), 0));
</script>

<div class="space-y-3">
	<div class="flex items-baseline justify-between gap-2">
		<h3 class="text-sm font-semibold text-slate-800">Splits</h3>
		<span class="font-mono text-xs text-slate-500">
			Running {formatSwimTime(running)}
			{#if finalTimeMs}
				/ final {formatSwimTime(finalTimeMs)}
			{/if}
		</span>
	</div>
	<div class="grid grid-cols-2 gap-2 sm:grid-cols-4">
		{#each fields as _, i}
			<label class="block text-xs">
				<span class="mb-1 block text-slate-500">Split {i + 1}</span>
				<input
					type="text"
					inputmode="decimal"
					class="w-full rounded-md border border-slate-300 px-2 py-1.5 font-mono text-sm"
					bind:value={fields[i]}
					placeholder="ss.ss"
				/>
			</label>
		{/each}
	</div>
	{#if check}
		{#if check.ok}
			<p class="text-xs text-teal-700">Splits sum matches final within ±{toleranceMs} ms.</p>
		{:else}
			<p class="text-xs font-medium text-rose-700">
				Splits sum {formatSwimTime(check.sum)} differs from final by {check.delta} ms (tolerance ±{toleranceMs}
				ms).
			</p>
		{/if}
	{/if}
</div>
