<script lang="ts">
	import DQBadge from '$lib/components/DQBadge.svelte';
	import PacingChart from '$lib/components/PacingChart.svelte';
	import { formatSwimTime } from '$lib/swim/time';
	import { splitsMatchFinal } from '$lib/swim/splits';
	import type { ActionData, PageData } from './$types';

	let { data, form }: { data: PageData; form: ActionData } = $props();
	const tolerance = 100;
</script>

<svelte:head><title>Verify performances · SwimIndex</title></svelte:head>

<div class="space-y-6">
	<header>
		<h1 class="text-3xl font-semibold text-teal-950">Verify performances</h1>
		<p class="mt-1 text-sm text-slate-600">
			Surface DQ status and split-sum checks before approval. DQ’d times never enter the index.
		</p>
	</header>

	{#if form?.success}
		<p class="rounded-lg bg-teal-50 px-4 py-3 text-sm text-teal-900">
			{form.message ?? 'Updated.'}
		</p>
	{/if}

	{#if data.demoMode}
		<p class="rounded-lg bg-amber-50 px-4 py-3 text-sm text-amber-950">
			Demo queue — approve/reject runs the UI flow only (nothing is saved).
		</p>
	{:else if !data.canVerify}
		<p class="rounded-lg bg-amber-50 px-4 py-3 text-sm text-amber-950">
			Coach or admin role required for actions.
		</p>
	{/if}

	<div class="space-y-4">
		{#each data.pending as item}
			{@const splitCheck =
				item.splits && item.splits.length
					? splitsMatchFinal(item.splits, item.time_ms, tolerance)
					: null}
			<article class="rounded-xl border border-slate-200 bg-white/80 p-5 shadow-sm">
				<div class="flex flex-wrap items-start justify-between gap-3">
					<div>
						<h2 class="font-semibold text-teal-950">{item.swimmer}</h2>
						<p class="text-sm text-slate-600">
							{item.event} · {item.meet} ({item.meet_level}) · {item.competition_date}
						</p>
						<p class="mt-2 font-mono text-2xl tabular-nums">{formatSwimTime(item.time_ms)}</p>
					</div>
					{#if item.dq}
						<DQBadge reason={item.dq_reason} />
					{/if}
				</div>

				{#if item.splits}
					<div class="mt-4">
						<PacingChart splits={item.splits} />
						{#if splitCheck}
							<p
								class="mt-2 text-xs {splitCheck.ok
									? 'text-teal-700'
									: 'font-medium text-rose-700'}"
							>
								{#if splitCheck.ok}
									Splits sum within ±{tolerance} ms of final.
								{:else}
									Split sum mismatch: delta {splitCheck.delta} ms — investigate before approving.
								{/if}
							</p>
						{/if}
					</div>
				{/if}

				<form method="POST" class="mt-4 flex flex-wrap gap-2">
					<input type="hidden" name="id" value={item.id} />
					<button
						name="decision"
						value="verify"
						class="rounded-lg bg-teal-700 px-4 py-2 text-sm font-semibold text-white hover:bg-teal-600 disabled:opacity-40"
						disabled={item.dq || (splitCheck != null && !splitCheck.ok) || !data.canVerify}
					>
						Approve
					</button>
					<button
						name="decision"
						value="reject"
						class="rounded-lg border border-slate-300 px-4 py-2 text-sm font-medium hover:bg-slate-50"
						disabled={!data.canVerify}
					>
						Reject
					</button>
				</form>
			</article>
		{/each}
	</div>
</div>
