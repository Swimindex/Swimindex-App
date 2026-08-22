<script lang="ts">
	import type { Course } from '$lib/types/swim';

	interface Props {
		course: Course;
		class?: string;
	}

	let { course, class: className = '' }: Props = $props();

	const tones: Record<Course, string> = {
		SCY: 'bg-teal-100 text-teal-900 ring-teal-200',
		SCM: 'bg-sky-100 text-sky-900 ring-sky-200',
		LCM: 'bg-indigo-100 text-indigo-950 ring-indigo-200'
	};
</script>

<span
	class="inline-flex items-center rounded-md px-1.5 py-0.5 font-mono text-[0.7rem] font-semibold tracking-wide ring-1 ring-inset {tones[
		course
	]} {className}"
	title="{course} — times are not directly comparable across courses"
>
	{course}
</span>
