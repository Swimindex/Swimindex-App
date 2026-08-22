# SwimIndex

Clock-based swimming rankings: verified meet times scored with a World Aquatics–style points table, plus a fair **age-adjusted** index for developing swimmers.

## Stack

- **SvelteKit** (Svelte 5 + TypeScript)
- **Supabase** (Postgres, Auth, Edge Functions, RLS)
- **Cloudflare Pages** (`@sveltejs/adapter-cloudflare`)
- **Tailwind CSS** + **Zod**

## Domain highlights (v2)

- Canonical **events catalog** (legal stroke × distance × course only)
- **SCY / SCM / LCM** kept separate; conversions are labeled estimates
- **Open Index** + **Age-Adjusted Index** (`1000 × (standard / time)³`)
- **Seasonal age** (default Sep 1) for age-group bucketing
- DQ + split-sum checks on coach verify
- Recruiting-standard badges from seed cuts (update yearly)
- Scheduled Edge Functions: nightly index recompute + season aging-up

## Local setup

```bash
cp .env.example .env
# set PUBLIC_SUPABASE_URL + PUBLIC_SUPABASE_ANON_KEY
npm install
npm run dev
```

Without Supabase keys, pages render with **demo data**.

### Database

Apply in order:

1. `supabase/migrations/0001_schema.sql`
2. `supabase/migrations/0002_index_functions.sql`
3. `supabase/migrations/0003_rls.sql`
4. Seed files under `supabase/seed/` (events → standards → conversions → recruiting)

### Edge Functions

- `supabase/functions/recompute-indices` — nightly composite recompute
- `supabase/functions/age-group-aging-up` — season-boundary seasonal age refresh

## Scripts

```bash
npm test
npm run check
npm run build
```

## Docs

- [Index formula](docs/index-formula.md)
- [Implementation plan](docs/implementation-plan.md)

## Known integrity checks

- Splits sum vs final (±100 ms default)
- DQ never enters index / PBs
- Seasonal age on Sep 1 boundary
- Converted times never overwrite recorded times
- Relay legs excluded from individual composite
