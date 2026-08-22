<script lang="ts">
	import {
		COURSE_LABELS,
		STROKE_LABELS,
		type Course,
		type EventCatalogRow,
		type Stroke
	} from '$lib/types/swim';

	interface Props {
		events: EventCatalogRow[];
		value?: string | null;
		allowRelays?: boolean;
		onselect?: (event: EventCatalogRow | null) => void;
	}

	let { events, value = $bindable(null), allowRelays = false, onselect }: Props = $props();

	let course = $state<Course | ''>('');
	let stroke = $state<Stroke | ''>('');
	let distance = $state<number | ''>('');

	const catalog = $derived(events.filter((e) => allowRelays || !e.is_relay));
	const courses = $derived([...new Set(catalog.map((e) => e.course))].sort() as Course[]);
	const strokes = $derived(
		course
			? ([
					...new Set(catalog.filter((e) => e.course === course).map((e) => e.stroke))
				].sort() as Stroke[])
			: []
	);
	const distances = $derived(
		course && stroke
			? [
					...new Set(
						catalog
							.filter((e) => e.course === course && e.stroke === stroke)
							.map((e) => e.distance_m)
					)
				].sort((a, b) => a - b)
			: []
	);
	const selected = $derived(
		course && stroke && distance
			? (catalog.find(
					(e) => e.course === course && e.stroke === stroke && e.distance_m === distance
				) ?? null)
			: null
	);

	$effect(() => {
		if (value) {
			const match = catalog.find((e) => e.id === value);
			if (match) {
				course = match.course;
				stroke = match.stroke;
				distance = match.distance_m;
			}
		}
	});

	$effect(() => {
		value = selected?.id ?? null;
		onselect?.(selected);
	});
</script>

<fieldset class="space-y-3">
	<legend class="text-sm font-semibold text-slate-800">Event</legend>
	<p class="text-xs text-slate-500">
		Only legal stroke / distance / course combinations from the catalog.
	</p>
	<div class="grid gap-3 sm:grid-cols-3">
		<label class="block text-sm">
			<span class="mb-1 block text-slate-600">Course</span>
			<select
				class="w-full rounded-lg border border-slate-300 bg-white px-3 py-2"
				bind:value={course}
				onchange={() => {
					stroke = '';
					distance = '';
				}}
			>
				<option value="">Select</option>
				{#each courses as c}
					<option value={c}>{COURSE_LABELS[c]}</option>
				{/each}
			</select>
		</label>
		<label class="block text-sm">
			<span class="mb-1 block text-slate-600">Stroke</span>
			<select
				class="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 disabled:opacity-50"
				bind:value={stroke}
				disabled={!course}
				onchange={() => {
					distance = '';
				}}
			>
				<option value="">Select</option>
				{#each strokes as s}
					<option value={s}>{STROKE_LABELS[s]}</option>
				{/each}
			</select>
		</label>
		<label class="block text-sm">
			<span class="mb-1 block text-slate-600">Distance</span>
			<select
				class="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 disabled:opacity-50"
				bind:value={distance}
				disabled={!stroke}
			>
				<option value="">Select</option>
				{#each distances as d}
					<option value={d}>{d}</option>
				{/each}
			</select>
		</label>
	</div>
	{#if selected}
		<p class="rounded-lg bg-teal-50 px-3 py-2 text-sm text-teal-900 ring-1 ring-teal-100">
			{selected.label}
		</p>
	{/if}
</fieldset>
