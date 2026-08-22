# SwimIndex index formula

Mirrors the **World Aquatics / FINA points table** approach (clock vs standard), not opponent Elo.

## Event index

```
event_index = 1000 × (standard_time / swimmer_time)³
```

- **Open Index** — `standard_times` (elite/open)
- **Age-Adjusted Index** — `age_group_standard_times` matched to seasonal age at the meet + gender

Only **verified, non-DQ, non-relay** performances score.

## Composite

1. Best verified event index per canonical event (course-specific)
2. Weighted average of top N (default 5)
3. Weights: recency half-life (default 365d) × meet-level weight (dual → olympic_trials)

## Not the index

- **Personal bests** — primary profile content; course-grouped
- **Converted equivalents** — optional, labeled estimates from `course_conversion_factors`

## Adjustable seed constants

Standard times, AG standards, conversion factors, meet weights, half-life, top-N, and recruiting cuts live in DB seed / `app_config` — not hardcoded app logic.
