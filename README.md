# SwimIndex

Clock-based swimming rankings: verified meet times scored with a World Aquatics–style points table, plus a fair **age-adjusted** index for developing swimmers.

## Stack

- **SvelteKit** (Svelte 5 + TypeScript)
- **Supabase** (Postgres, Auth, Edge Functions, RLS)
- **Cloudflare Workers** (`@sveltejs/adapter-cloudflare` + static assets)
- **Tailwind CSS** + **Zod**

## Domain highlights (v2)

- Canonical **events catalog** (legal stroke × distance × course only)
- **SCY / SCM / LCM** kept separate; conversions are labeled estimates
- **Open Index** + **Age-Adjusted Index** (`1000 × (standard / time)³`)
- **Seasonal age** (default Sep 1) for age-group bucketing
- DQ + split-sum checks on coach verify
- Recruiting-standard badges from seed cuts (update yearly)
- Scheduled Edge Functions: nightly index recompute + season aging-up

## Local setup (demo / client pitch)

```bash
cp .env.example .env   # PUBLIC_DEMO_MODE=true by default
npm install
npm run dev
```

Open `/` → **Start client demo**, or use the header persona switcher:

- **Swimmer** — profile, PBs, scholarships, submit
- **Coach** — verify queue (DQ + split checks)
- **Admin** — reference tables & scheduled jobs

No Supabase account required. All data is sample.

### Live backend (later)

Set `PUBLIC_DEMO_MODE=false` and fill Supabase keys in `.env`, then apply migrations + seeds.

## Scripts

```bash
npm test
npm run check
npm run build
npm run preview   # wrangler dev after build
npm run deploy    # build + wrangler deploy (production)
npm run cf:upload # build + wrangler versions upload (preview version)
```

## Cloudflare Workers Builds

Wrangler generates `.svelte-kit/cloudflare/_worker.js` via `build.command` in `wrangler.jsonc` (`npx vite build`) before upload — so a deploy command of only `npx wrangler versions upload` still works.

Recommended dashboard settings (Worker → **Settings → Build**):

| Setting | Value |
| --- | --- |
| **Build command** | `npm run build` (optional; wrangler also builds) |
| **Deploy command** (production) | `npx wrangler deploy` |
| **Non-production deploy command** | `npx wrangler versions upload` |

`PUBLIC_DEMO_MODE=true` is set in `wrangler.jsonc` vars for the client demo (leave Supabase keys empty).

## Docs

- [Index formula](docs/index-formula.md)
- [Implementation plan](docs/implementation-plan.md)

## Known integrity checks

- Splits sum vs final (±100 ms default)
- DQ never enters index / PBs
- Seasonal age on Sep 1 boundary
- Converted times never overwrite recorded times
- Relay legs excluded from individual composite
