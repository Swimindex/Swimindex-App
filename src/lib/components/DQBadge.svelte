<script lang="ts">
	import { DQ_REASON_LABELS, type DqReason } from '$lib/types/swim';

	interface Props {
		reason?: DqReason | null;
		compact?: boolean;
	}

	let { reason = null, compact = false }: Props = $props();
</script>

<span
	class="inline-flex items-center gap-1 rounded-md bg-rose-100 px-2 py-0.5 text-xs font-semibold uppercase tracking-wide text-rose-900 ring-1 ring-inset ring-rose-200"
	title={reason ? DQ_REASON_LABELS[reason] : 'Disqualified — not a valid ranked result'}
>
	DQ
	{#if !compact && reason}
		<span class="font-normal normal-case tracking-normal text-rose-800"
			>· {DQ_REASON_LABELS[reason]}</span
		>
	{/if}
</span>
