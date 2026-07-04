# Lead playbook — failure modes and fetch recovery

Load this from SKILL.md when running in degraded mode (no `Agent` tool) or
when judging Worker output.

## Common failure modes

| Failure | Symptom | Fix |
|---------|---------|-----|
| Echo chamber | Workers all cite the same blog/SEO content | Force domain diversity in Phase 1 `sources`; enforce `min_independent_sources` |
| Empty citations | URL is real but doesn't support the claim | Risk-first verification in Phase 3; Critic re-fetch in Phase 4 |
| Context bloat | Workers return prose walls; Lead's context fills | Tighten OUTPUT FORMAT; run Phase 2.5 |
| Plan staleness | Findings invalidate the plan but the Lead keeps executing it | Replan after Phase 3 when synthesis breaks an assumption |
| Contradiction smoothing | Synthesis reads coherent but hides disagreement | Phase 3 rule 1: name contradictions, never average |
| Over-parallelization | Far more Workers than the question warrants; outputs converge on the same shallow story | Classify query type (Phase 1 table) before fan-out; apply the per-round cap (§ Budgets) |
| Vague briefing | Workers misinterpret the task, duplicate searches | Reject any sub-question missing one of the eight fields |
| Lead helicoptering | Lead searches or re-does Worker tasks, burns its own context | Lead never searches during fan-out — dispatch another Worker |

## Fetch failure recipe (Lead-side detail)

Workers get the condensed rules inside their prompt template. This fuller
table is for the Lead running in degraded mode (no `Agent` tool) and for
judging Worker output:

| Failure mode | Recovery move |
|---|---|
| 404 / path moved | Search the site (`site:domain.com <topic>`) or fetch `/sitemap.xml` to rediscover the canonical path. Don't retry the dead URL. |
| Timeout (>30s) on a flaky site (gov, large PDFs, JS-heavy docs) | Retry exactly once. Then: (a) `web.archive.org` snapshot, (b) triangulate across 2 independent secondaries that cite the primary, marking the claim "primary not directly verified". |
| JS-only / SPA redirect shell | Use the API behind it: `raw.githubusercontent.com` for repo files; vendor REST endpoints. For GitHub metadata prefer `gh api repos/{owner}/{repo}/...` over scraping HTML. |
| Paywall / login wall | Don't keep retrying. Note as a user-side suggestion (`references/source_access.md`) and propose a free alternative. |
| Stale-without-date page | Compare `web.archive.org` first-seen vs latest snapshot. Stable >12 months → mark `[STALE-RISK: undated]`. |
