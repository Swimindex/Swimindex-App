# Implementation plan

1. Scaffold SvelteKit + Tailwind + Cloudflare adapter  
2. Supabase schema + RLS + index RPCs  
3. **Seed reference data** (events, standards, conversions, recruiting cuts)  
4. Auth pages  
5. Swim libs (time, seasonal age, index, splits, conversion)  
6. Swim-specific components  
7. Pages: rankings, profile (PBs first), scholarships, submit, verify, admin  
8. Edge Functions: nightly recompute + season aging-up  
9. Docs + unit tests  

## Bug checklist

- [ ] Splits sum ≠ final (tolerance)  
- [ ] DQ counted in index  
- [ ] Seasonal-age Sep 1 boundary  
- [ ] Cross-course conversion misread as actual  
- [ ] Relay leg double-count  

## Next improvements

- Para-swimming S1–S14 standards  
- Open-water / pace index  
- Meet Manager / Hy-Tek CSV import  
- Stroke-rate analytics from video  
