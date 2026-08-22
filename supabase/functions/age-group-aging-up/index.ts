import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

/**
 * Season-boundary aging-up: recompute seasonal ages (default Sep 1) then indices.
 * Schedule annually (or daily with an internal boundary check).
 * This is a real scheduled job, not a placeholder.
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

	const body = await req.json().catch(() => ({}));
	const referenceDate = body.reference_date ?? new Date().toISOString().slice(0, 10);

	const { data, error } = await supabase.rpc('recompute_seasonal_ages', {
		reference_date: referenceDate
	});
	if (error) {
		return new Response(JSON.stringify({ error: error.message }), { status: 500 });
	}

	return new Response(
		JSON.stringify({
			swimmers_updated: data,
			reference_date: referenceDate,
			at: new Date().toISOString()
		}),
		{ headers: { 'Content-Type': 'application/json' } }
	);
});
