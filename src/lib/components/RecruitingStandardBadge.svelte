<script lang="ts">
	interface Props {
		label: string;
		tier?: string;
	}

	let { label, tier }: Props = $props();
</script>

<span
	class="inline-flex items-center gap-1.5 rounded-md bg-amber-50 px-2.5 py-1 text-xs font-semibold text-amber-950 ring-1 ring-inset ring-amber-200"
	title="Derived from verified personal bests vs sample recruiting standards (seed data — cuts change yearly)"
>
	{#if tier}
		<span class="rounded bg-amber-200/80 px-1 font-mono text-[0.65rem] uppercase">{tier}</span>
	{/if}
	{label}
</span>
