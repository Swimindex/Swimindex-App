<script lang="ts">
	import type { IndexMode } from '$lib/types/swim';

	interface Props {
		value?: IndexMode;
		onchange?: (mode: IndexMode) => void;
	}

	let { value = $bindable('open'), onchange }: Props = $props();

	function setMode(mode: IndexMode) {
		value = mode;
		onchange?.(mode);
	}
</script>

<div
	class="inline-flex rounded-lg bg-slate-100 p-1 text-sm ring-1 ring-slate-200"
	role="group"
	aria-label="Index mode"
>
	<button
		type="button"
		class="rounded-md px-3 py-1.5 font-medium transition {value === 'open'
			? 'bg-white text-slate-900 shadow-sm'
			: 'text-slate-600 hover:text-slate-900'}"
		onclick={() => setMode('open')}
	>
		Open Index
	</button>
	<button
		type="button"
		class="rounded-md px-3 py-1.5 font-medium transition {value === 'age_adjusted'
			? 'bg-white text-slate-900 shadow-sm'
			: 'text-slate-600 hover:text-slate-900'}"
		onclick={() => setMode('age_adjusted')}
	>
		Age-Adjusted
	</button>
</div>
