<script lang="ts">
	import { formatSwimTime, parseSwimTime } from '$lib/swim/time';

	interface Props {
		valueMs?: number | null;
		label?: string;
		id?: string;
		required?: boolean;
		disabled?: boolean;
		onChangeMs?: (ms: number | null) => void;
	}

	let {
		valueMs = $bindable(null),
		label = 'Time',
		id = 'time-input',
		required = false,
		disabled = false,
		onChangeMs
	}: Props = $props();

	let display = $state('');
	let error = $state<string | null>(null);

	$effect(() => {
		if (valueMs != null && typeof document !== 'undefined' && document.activeElement?.id !== id) {
			display = formatSwimTime(valueMs);
		}
	});

	function commit() {
		if (!display.trim()) {
			valueMs = null;
			error = required ? 'Time required' : null;
			onChangeMs?.(null);
			return;
		}
		const parsed = parseSwimTime(display);
		if (parsed == null) {
			error = 'Use mm:ss.ss or ss.ss (e.g. 28.45 or 1:02.31)';
			onChangeMs?.(null);
			return;
		}
		error = null;
		valueMs = parsed;
		display = formatSwimTime(parsed);
		onChangeMs?.(parsed);
	}
</script>

<label class="block text-sm" for={id}>
	<span class="mb-1 block font-medium text-slate-700">{label}</span>
	<input
		{id}
		type="text"
		inputmode="decimal"
		placeholder="28.45 or 1:02.31"
		class="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 font-mono text-slate-900 shadow-sm outline-none focus:border-teal-600 focus:ring-2 focus:ring-teal-600/20 disabled:opacity-60"
		bind:value={display}
		{disabled}
		{required}
		onblur={commit}
		onkeydown={(e) => e.key === 'Enter' && commit()}
	/>
	{#if error}
		<span class="mt-1 block text-xs text-rose-700">{error}</span>
	{:else}
		<span class="mt-1 block text-xs text-slate-500">mm:ss.ss or sub-minute ss.ss</span>
	{/if}
</label>
