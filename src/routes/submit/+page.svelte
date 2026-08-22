<script lang="ts">
	import EventSelector from '$lib/components/EventSelector.svelte';
	import SplitsInput from '$lib/components/SplitsInput.svelte';
	import TimeInput from '$lib/components/TimeInput.svelte';
	import type { Course, EventCatalogRow } from '$lib/types/swim';
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();

	let eventId = $state<string | null>(null);
	let selected = $state<EventCatalogRow | null>(null);
	let timeMs = $state<number | null>(null);
	let splits = $state<number[] | null>(null);
	let dq = $state(false);

	let course = $derived((selected?.course ?? 'SCY') as Course);
	let distanceM = $derived(selected?.distance_m ?? 100);
</script>

<svelte:head><title>Submit performance · SwimIndex</title></svelte:head>

<div class="mx-auto max-w-2xl space-y-6">
	<header>
		<h1 class="text-3xl font-semibold text-teal-950">Submit a swim</h1>
		<p class="mt-1 text-sm text-slate-600">
			Pending coach verification. DQ’d swims never enter the index.
		</p>
	</header>

	<form method="POST" class="space-y-6 rounded-xl border border-slate-200 bg-white/80 p-6 shadow-sm">
		<EventSelector
			events={data.events}
			bind:value={eventId}
			onselect={(e) => {
				selected = e;
			}}
		/>
		<input type="hidden" name="event_catalog_id" value={eventId ?? ''} />

		<label class="block text-sm">
			<span class="mb-1 block font-medium">Meet name</span>
			<input name="meet_name" required class="w-full rounded-lg border border-slate-300 px-3 py-2" />
		</label>

		<div class="grid gap-4 sm:grid-cols-2">
			<label class="block text-sm">
				<span class="mb-1 block font-medium">Meet level</span>
				<select name="meet_level" class="w-full rounded-lg border border-slate-300 px-3 py-2">
					<option value="dual">Dual</option>
					<option value="invitational" selected>Invitational</option>
					<option value="sectional">Sectional</option>
					<option value="state">State</option>
					<option value="national">National</option>
					<option value="international">International</option>
					<option value="olympic_trials">Olympic Trials</option>
				</select>
			</label>
			<label class="block text-sm">
				<span class="mb-1 block font-medium">Date</span>
				<input
					name="competition_date"
					type="date"
					required
					class="w-full rounded-lg border border-slate-300 px-3 py-2"
				/>
			</label>
		</div>

		<TimeInput bind:valueMs={timeMs} label="Final time" required />
		<input type="hidden" name="time_ms" value={timeMs ?? ''} />

		{#if selected && !selected.is_relay}
			<SplitsInput {distanceM} {course} finalTimeMs={timeMs} bind:value={splits} />
			<input type="hidden" name="splits" value={splits ? JSON.stringify(splits) : ''} />
		{/if}

		<label class="flex items-center gap-2 text-sm">
			<input type="checkbox" bind:checked={dq} />
			<span>Disqualified (DQ)</span>
		</label>
		<input type="hidden" name="dq" value={dq ? 'true' : 'false'} />
		{#if dq}
			<label class="block text-sm">
				<span class="mb-1 block font-medium">DQ reason</span>
				<select name="dq_reason" class="w-full rounded-lg border border-slate-300 px-3 py-2">
					<option value="false_start">False start</option>
					<option value="stroke_infraction">Stroke infraction</option>
					<option value="illegal_turn">Illegal turn</option>
					<option value="illegal_finish">Illegal finish</option>
					<option value="other">Other</option>
				</select>
			</label>
		{/if}

		<button
			type="submit"
			class="rounded-lg bg-teal-700 px-5 py-2.5 font-semibold text-white hover:bg-teal-600 disabled:opacity-50"
			disabled={!data.canSubmit || !eventId || timeMs == null}
		>
			{data.canSubmit ? 'Submit for verification' : 'Sign in to submit (demo UI only)'}
		</button>
	</form>
</div>
