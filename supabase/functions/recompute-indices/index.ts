import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

/**
 * Nightly recompute of swimmer open + age-adjusted composite indices.
 * Schedule via Supabase cron (e.g. 0 6 * * *).
 */
Deno.serve(async (req) => {
	const auth = req.headers.get('Authorization');
	const cronSecret = Deno.env.get('CRON_SECRET');
	if (cronSecret && auth !== `Bearer ${cronSecret}`) {
		return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 });
	}

	const url = Deno.env.get('SUPABASE_URL')!;
	const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
	const supabase = createClient(url, key);

	const { data, error } = await supabase.rpc('recompute_all_indices');
	if (error) {
		return new Response(JSON.stringify({ error: error.message }), { status: 500 });
	}

	return new Response(JSON.stringify({ recomputed: data, at: new Date().toISOString() }), {
		headers: { 'Content-Type': 'application/json' }
	});
});
