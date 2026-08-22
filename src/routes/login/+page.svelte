<script lang="ts">
	import type { ActionData, PageData } from './$types';

	let { data, form }: { data: PageData; form: ActionData } = $props();
</script>

<svelte:head><title>Log in · SwimIndex</title></svelte:head>

<div class="mx-auto max-w-md space-y-6">
	<h1 class="text-3xl font-semibold text-teal-950">Log in</h1>
	<p class="text-sm text-slate-600">Magic link via Supabase Auth. Configure keys in <code>.env</code>.</p>

	{#if form?.error}
		<p class="rounded-lg bg-rose-50 px-3 py-2 text-sm text-rose-800">{form.error}</p>
	{/if}
	{#if form?.success}
		<p class="rounded-lg bg-teal-50 px-3 py-2 text-sm text-teal-900">
			Check your email for a magic link.
		</p>
	{/if}

	<form method="POST" class="space-y-4 rounded-xl border border-slate-200 bg-white/80 p-6 shadow-sm">
		<label class="block text-sm">
			<span class="mb-1 block font-medium">Email</span>
			<input
				name="email"
				type="email"
				required
				class="w-full rounded-lg border border-slate-300 px-3 py-2"
				placeholder="you@club.org"
			/>
		</label>
		<button
			type="submit"
			class="w-full rounded-lg bg-teal-700 px-4 py-2.5 font-semibold text-white hover:bg-teal-600"
			disabled={!data.authEnabled}
		>
			{data.authEnabled ? 'Send magic link' : 'Auth not configured'}
		</button>
	</form>

	<p class="text-sm text-slate-600">
		No account? <a class="text-teal-800 underline" href="/signup">Sign up</a>
	</p>
</div>
