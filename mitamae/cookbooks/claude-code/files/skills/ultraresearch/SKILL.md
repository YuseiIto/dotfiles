---
name: ultraresearch
description: Use when the user explicitly asks for "ultraresearch" or a rigorous multi-source investigation — comparative surveys, hypothesis testing, decision-driving research ("徹底調査", "深く調べて"). Prefer over deep-research when the question needs scope clarification (interview), Japanese/paywalled source guidance, or red-team falsification. Not for single-fact lookups.
allowed-tools: Agent, AskUserQuestion, TaskCreate, TaskUpdate, TaskList, WebSearch, WebFetch, Read, Write, Glob, Grep, Bash
---

# Ultraresearch

Deep, broad, verified research via an orchestrator-worker loop: parallel
Workers, citation-first synthesis, and an externally grounded Critic gate.

## Roles (fixed vocabulary)

Four roles. Use exactly these names throughout a run:

- **Lead** — plans, dispatches, synthesizes. Never searches during fan-out;
  when tempted, dispatch another Worker instead.
- **Worker** — isolated context, one sub-question. May spend heavily on
  exploration but returns only a distilled structured summary plus citations
  — never raw logs or walls of text.
- **Critic** — gates the synthesis before delivery (an acceptance function,
  not an afterthought). Critique works only with external grounding:
  re-fetchable sources, a different model, or a written rubric. Ungrounded
  self-critique measurably reduces accuracy (provenance:
  `references/methodology_basis.md`).
- **Red-team** — attacks the conclusion itself, not the citations.

Anthropic reported multi-agent research costing ~15× typical chat usage.
Reserve this skill for tasks where correctness matters more than tokens.

## Progress checklist

Copy into your response and update as you go:

```
Ultraresearch Progress:
- [ ] Phase 1 — Plan: classify query, set budgets, write 8-field sub-questions
- [ ] Phase 2 — Dispatch all Workers in a single turn
- [ ] Phase 2.5 — Compress (only if a Worker returned >30 lines of prose)
- [ ] Phase 3 — Synthesize; re-dispatch while key questions remain unanswered
- [ ] Phase 3.5 — Red-team (only if the deliverable drives a decision)
- [ ] Phase 4 — Critic gate (default ON; skip only if no external grounding)
- [ ] Phase 5 — Deliver: executive answer, citations, gaps, next steps
```

Where Task tools are available, mirror these items via
`TaskCreate`/`TaskUpdate` so the user can watch progress.

## Citation markers (canonical list)

All roles tag claims with these markers — no ad-hoc variants:

| Marker | Assigned by | Meaning |
|---|---|---|
| `[UNVERIFIED]` | Worker / Lead / Critic | No supporting source found; included for the Lead to judge |
| `[SINGLE-SOURCE]` | Worker | Could not triangulate to a second independent source |
| `[SNIPPET-ONLY]` | Worker | Quote taken from a search snippet; page never fetched |
| `[SINGLE-SOURCE-ECHO]` | Worker / Lead | Same number repeated across secondaries; no origin found |
| `[STALE-RISK: undated]` | Worker / Critic | Undated page whose archive snapshots are stable >12 months |
| `[STALE: as-of YYYY-MM]` | Critic | Source older than the topic's half-life (`references/source_critique.md`) |

The Critic adds source-metadata markers (`[ANONYMOUS]`, `[VENDOR-SOURCE]`,
`[SECONDARY-ONLY]`, `[POSSIBLE-AI-CONTENT]`, `[NUANCE-RISK]`) defined in
`references/source_critique.md`. A claim still carrying any marker at
Phase 5 keeps the marker visible in the deliverable.

## Phase 1 — Plan (Lead only)

Classify the query, then size the fan-out from this table:

| Query type | Shape | Workers | Tool calls per Worker |
|---|---|---|---|
| Straightforward | one fact, one source | 0 — exit this skill | — |
| Depth-first | one topic, several angles to triangulate | 3–5, one per angle | 10–15 |
| Breadth-first | several independent sub-topics | up to 10 per round, one per sub-topic | as scoped |
| Mixed | sub-topics × per-topic triangulation | split by sub-topic; put triangulation into each Worker's key_questions | 10–15 |

Tool calls per Worker ≈ searches + fetches in `tool_budget`; raise the
defaults (S=6, F=4, total 10) when the table calls for more than 10.

To generate angles and sub-topics, walk this list: rival hypotheses,
stakeholders, time windows, populations, edge conditions, strongest
counter-example.

Set the run budgets now and record them in the plan (§ Budgets and stop
conditions).

Write one sub-question per Worker — counts follow the table above. Every
sub-question carries **all eight fields** — a missing field is the main
cause of duplicate or off-target Workers:

```
- id:            q1
- objective:     one sentence — what question this Worker answers
- output_format: structured shape the Worker must return
                 (e.g. "table of {framework, plan_phase, parallelism}")
- sources:       where to look first — require domain diversity
                 (e.g. "≥1 official doc, ≥1 academic or primary, no SEO farms")
- min_independent_sources: per major claim (default 2)
- key_questions: 3–5 specific questions the Worker must answer
- tool_budget:   split discovery from verification (default "≤6 searches,
                 ≤4 fetches, ≤15 min wall time") — without the split,
                 Workers spend everything on discovery and verify nothing
- scope:         what is explicitly out of scope (prevents drift)
```

If the question is fuzzy:

- **Trivial fuzziness** (one missing piece — version, scope, deadline): ask
  the user **one** clarifying question; pick the one that most changes the
  plan.
- **Non-trivial fuzziness** (stated request and actual information need
  diverge — e.g. "compare A and B" without saying *for what decision*):
  load `references/interview.md` and follow it. This section only decides
  when to *load* that file; the file itself owns the run/skip decision
  (stakes-based) and the ≤3-question batched template, and it supersedes
  the one-question rule above.

The interview runs **before** any delegation or stack-specific skill load
(org delegation tables, stack coding rules, …) — clarification is scope
formation, not execution. Never delegate the raw fuzzy prompt or load
stack skills speculatively; the answer may invalidate the assumed stack.
Once answered, decide: research (stay here) or implementation (delegate).

Write the plan (budgets, sub-questions) to a `notes/` directory under the
session scratchpad (never the user's repo); all later `notes/` paths are
relative to it.

## Phase 2 — Dispatch (parallel fan-out)

Spawn all independent Workers in **a single assistant turn** with multiple
`Agent` tool calls. Sequential dispatch wastes wall time and breaks the
parallelism the pattern depends on.

Per-round dispatch cap: § Budgets and stop conditions.

Sub-agent type per Worker: `Explore` (read-only file/codebase search),
`claude-code-guide` (Claude Code / API questions), `general-purpose`
(open-ended web research), `Plan` (the Worker's job is designing an
approach).

Build each Worker prompt from § Worker prompt template. The template is the
**only contract** between Lead and Worker — the Worker reads nothing else,
so every rule the Worker must follow has to appear inside the prompt. Fill
every placeholder; never reference SKILL.md sections from inside a Worker
prompt.

## Phase 2.5 — Compress (if a Worker returned >30 lines of prose)

Compression cannot shrink context you have already consumed — its payoff is
in what you carry forward: the synthesis prompt, `notes/` files, and
next-round dispatches.

- Re-summarize each oversized output to ≤15 lines of structured findings in
  `notes/findings/{id}.md`. Keep every citation (citations are never
  truncated); drop prose, restatement, meta-commentary.
- Do it inline, or delegate to a compression Worker when several outputs
  are oversized (does not count against the research-Worker budget).
- From then on, reference the file, not the original output.
- Keep URLs as lightweight identifiers; re-fetch page content just-in-time
  instead of carrying it forward.

Token usage explains ~80% of performance variance in multi-agent research
(Anthropic) — context discipline is the work, not housekeeping.

## Phase 3 — Synthesize (Lead only)

1. **Surface contradictions.** Name each disagreement and the sources
   backing each side. Never average them away.
2. **Close coverage gaps.** If any key_question is unanswered and Worker
   budget remains, re-dispatch targeted Workers (back to Phase 2). Deliver
   a gap as a gap only when budget is exhausted or the user has agreed it
   is out of scope.
3. **Decompose claims for citations.** Every non-trivial claim carries a
   `source_url`; mark unsupported claims `[UNVERIFIED]` so the Critic can
   target them.
4. **Verify risk-first, not randomly.** Re-fetch and check: every claim the
   executive answer load-bears on, plus every `[SINGLE-SOURCE]` and
   `[SNIPPET-ONLY]` claim. Check against the fetched page text, not the
   Worker's restatement — Worker summaries describe what they *intended* to
   find.
5. **Anchor no major claim on an echo.** Numerical claims need an origin
   (methodology doc, official benchmark, named study). A number tagged
   `[SINGLE-SOURCE-ECHO]` may be quoted descriptively ("multiple
   secondaries report ~98%; no origin found") but never used as a
   major-claim anchor.

## Phase 3.5 — Red-team (run if the deliverable drives a decision)

Run when the deliverable feeds an adoption call, production migration,
hiring/legal/medical judgment, or a comparative recommendation. Skip when
the question is uncontested or the Red-team would see no sources the Lead
didn't.

Critique asks "are these claims supported"; Red-team asks "what would make
this conclusion wrong". Spawn one Red-team sub-agent with this brief:

```
Falsify the conclusion below. You are not a citation checker — you are an
opponent hunting the strongest counter-evidence, the most plausible
alternative explanation, and the dimension the synthesis ignored.

CONCLUSION: {executive answer + 2–3 key claims}
KEY CITATIONS THE CONCLUSION RESTS ON: {urls}
SCOPE (explicitly excluded): {out_of_scope}

Return:
1. The strongest single piece of counter-evidence you can find (primary
   source preferred).
2. The most plausible alternative conclusion consistent with the citations
   above. Steel-man it; do not strawman.
3. One dimension the Lead under-investigated (angle, population, time
   window, stakeholder, edge condition).
4. One fact that, if true, would flip the conclusion.

Budget: ≤4 searches, ≤3 fetches. Finding nothing after genuine effort is a
useful result — say so explicitly.
```

Verdicts:

- **Falsified** — primary counter-evidence found. Replan from Phase 1 with
  it as a sub-question; don't patch the old synthesis. **The replanned
  conclusion gets a fresh Red-team pass** — the cap below is per
  conclusion, not per run.
- **Tempered** — plausible alternative or missed dimension. Fold it into
  the synthesis as a named contradiction (Phase 3 rule 1 applies).
- **Held** — state in the deliverable: *"red-team pass found no primary
  counter-evidence."* Confidence goes up.

Cap: **1 Red-team pass per conclusion.** A second pass on the same
conclusion finds nits, not falsifications.

## Phase 4 — Critic gate (default ON)

The Critic is the acceptance gate between synthesis and delivery. Skip it
**only** when no external grounding exists — no re-fetchable citations, no
second model, no written rubric. ("Does this feel right" from the same
context is the documented failure mode, not grounding.)

Critic configuration:

- Spawn as `general-purpose` with a model override differing from the
  Lead's (a different model family or tier) — fresh context alone already
  breaks part of the self-preference bias.
- **Single call, single prompt**, returning a 0.0–1.0 score per rubric axis
  plus one verdict. This shape correlated best with human judgment in
  Anthropic's evals — better than multi-turn judging or open-ended
  narrative critique.
- Rubric axes: factual accuracy / citation accuracy / completeness /
  source quality.
- Phrase checks concretely ("is this claim supported by the cited source"),
  not holistically ("is this answer good") — concrete checks resist
  sycophancy.
- If comparing two outputs: randomize order; instruct the Critic to ignore
  length.
- Source metadata: load `references/source_critique.md` and run its
  PASS / NEEDS-CHECK / FAIL checklist whenever the deliverable will be
  acted on, the topic is recency-sensitive, or sources are mostly
  secondary. Its NEEDS-CHECK applies to individual claims (a marker
  trigger), not to this gate's verdict.

Verdicts: **PASS** → deliver. **NEEDS_IMPROVEMENT** → targeted re-dispatch
(Phase 2) on the named items only. **FAIL** → replan from Phase 1.
Iteration cap: § Budgets and stop conditions. If the verdict is still not
PASS at the cap, deliver anyway with the unresolved items listed as marked
gaps — don't stall.

## Phase 5 — Deliver

Return: executive answer first (the finding, not "here's what I did"), key
evidence with inline citations, named contradictions and gaps with
confidence calibration, and "what I'd investigate next if you want to go
deeper."

- **Paywalled / member-only sources you cannot reach** (legal, medical,
  patents, finance, analyst, JIS, J-PlatPat, NDL): name them with the exact
  search query and a free alternative — catalog and phrasing template in
  `references/source_access.md`. The user pasting back retrieved content is
  a normal next loop; invite it.
- **Never deliver a bare "couldn't find it."** Include what you tried, the
  closest near-miss, and one concrete next pointer (a query, an authority,
  an institution).
- **Close with an invitation to correct course** (translate to the user's
  language):

> Tell me if this misses the angle you expected. **From the use
> perspective** — if anything is missing or off-target for what you need
> this for — I will re-focus in that direction.

"From the use perspective" deliberately points back at motivation — that is
where mid-research re-interviews recover the most ground
(`references/interview.md` § Re-interview triggers).

- **Record unresolved deliveries.** When shipping with gaps, leave a
  one-line note in the plan (`notes/plan.md` when it exists) on why
  (paywall, ambiguous need, exhausted budget, contradictory sources) so a
  re-ask doesn't repeat the dead end.

## Convergence loop (Phases 2–5 repeat)

When the user pushes back or new sub-questions emerge: form explicit
hypotheses, treat each as a sub-question, re-enter Phase 2. Stop when
**both** hold:

- two consecutive iterations leave the executive answer unchanged, **and**
- no key_questions remain unanswered (or the remainder are gaps the user
  has accepted).

Answer stability alone is not convergence — Workers sharing the same blind
spot stabilize on the same wrong answer.

## Budgets and stop conditions (single source of truth)

Set at Phase 1; other sections defer to here.

- **Research Workers**: 15 total across all iterations. Critic, Red-team,
  and compression Workers do not count against this.
- **Per-round dispatch**: 10 Workers; exceed only with written division of
  labor in the plan.
- **Critic iterations**: 2. A third pass finds nits and burns tokens.
- **Wall clock**: announce a target up front; on overrun, deliver partial
  results with explicit gaps.
- **Stuck detection**: two consecutive replans without new information →
  stop and ask the user for direction.

## Worker prompt template

The Worker sees only this prompt — it must be self-contained. Fill every
`{placeholder}` from the sub-question's eight fields, plus a one-line
summary of the user task for `{one_line}`; budget defaults are S=6, F=4,
W=15. Translate to the user's language:

```
You are a research Worker. You have NONE of the Lead's context.

ORIGINAL USER TASK (context only; do not address directly):
{one_line}

YOUR SUB-QUESTION:
{objective}

KEY QUESTIONS YOU MUST ANSWER:
- {one bullet per key_question, 3–5}

OUTPUT FORMAT (return exactly this shape; distilled findings, no prose walls):
{output_format}
Each claim inside this format is a (claim, source_url, quote) triple (see
CITATIONS below). End with a NOTES section for markers, paywalled sources,
and anything that fits nowhere else.

SOURCES TO PRIORITIZE (domain diversity required):
{sources}

OUT OF SCOPE (do NOT investigate):
{scope}

BUDGET:
- ≤{S} searches (discovery), ≤{F} fetches (verification), ≤{W} min wall time
- Stop and return partial results when any limit hits. If you cannot track
  wall time, the search/fetch limits are the binding constraint.

FETCH FAILURES (a failed fetch and its single recovery move are
budget-free; triangulation fetches count normally. Apply the matching move
once, then mark and move on — never retry the same URL the same way):
- 404 → search `site:<domain> <topic>` to rediscover the moved page.
- Timeout → retry once; then web.archive.org snapshot, or triangulate via
  2 independent secondaries and note "primary not directly verified".
- JS-only shell → hit the API behind it (raw.githubusercontent.com, vendor
  REST endpoints).
- Paywall → stop; add (url, why it matters) to your NOTES section — the
  Lead will surface it to the user.
- Undated page → check web.archive.org snapshots; content unchanged for
  >12 months → mark [STALE-RISK: undated]; no snapshot → prefer another
  source.

CITATIONS — return claims as (claim, source_url, quote) triples:
- quote must be verbatim from a page you actually fetched. Search-snippet
  only → mark [SNIPPET-ONLY].
- ≥{min_independent_sources} independent sources (primary preferred) per
  major claim (default 2). Major claim = anything in your top-level
  findings; independent = different publishing organizations. Can't
  triangulate → mark [SINGLE-SOURCE].
- No source at all → mark [UNVERIFIED] and include the claim anyway; the
  Lead decides.
- Numbers ("~98%", "3× faster") need an origin (methodology doc, official
  benchmark, named study). Same number echoed across secondaries with no
  origin → mark [SINGLE-SOURCE-ECHO]; quote descriptively, don't adopt.
```

## Lead playbook (load on demand)

Load `references/lead_playbook.md` (failure-mode table + full fetch-failure
recipe) when running in degraded mode or judging Worker output.

## Long-running research (>200k context)

- Persist the plan and findings to files (`notes/plan.md`,
  `notes/findings/qN.md`) — never rely on conversation memory alone.
- Checkpoint state to the harness's persistent memory directory when one
  exists.
- Hand large artifacts to Workers via file paths, not pasted content.
- Approaching the limit: write a handoff note a cold agent could resume
  from, then start a new Lead.

## Tone for the user

One sentence between phases on what happens next. The user cares about the
synthesis, not the choreography.

## Environment degradation

When a tool is missing, degrade along these rows — don't abort, don't
silently route around. State in the deliverable which row applied.

| Missing | Fallback (do this) | What NOT to do |
|---|---|---|
| `Agent` | Lead executes each sub-question via parallel `WebSearch`/`WebFetch` calls in a single turn, treating each cluster as one "Worker" for budgeting. Write structured excerpts to `notes/` files and reference those downstream (Phase 2.5 mechanism). | Don't serialize the calls. Don't drop sub-questions — collapse them into the Lead's own budget. |
| `AskUserQuestion` | Render the interview as plain markdown (numbered list, bullet choices, free text for the real-need question) — `references/interview.md` § Plain-text rendering. Structure (≤3 questions, batched, mirrored vocabulary) is independent of the rendering tool. | Don't skip the interview. Don't ask one question per turn. |

If multiple rows apply, apply each independently and state all in the
deliverable.

## What this skill does NOT do

- It does not promise correctness — every output carries calibrated
  uncertainty.
- It does not replace human review for high-stakes decisions.
- It does not cache previous research — re-runs may diverge.
- It does not handle privileged sources (auth'd databases, paid APIs)
  unless the relevant MCP/tool is configured separately.

## Bundled references (load on demand)

Don't load these upfront — read each only at its trigger condition:

| File | Load when |
|------|-----------|
| `references/interview.md` | Phase 1 — stated request and actual information need diverge, or scope/format/deadline are unstated |
| `references/source_critique.md` | Phase 4 — deliverable will be acted on, topic is recency-sensitive, or sources are mostly secondary |
| `references/source_access.md` | Phase 1 or 5 — topic likely lives in a paywalled / member-only DB (academic, legal, medical, patents, finance, analyst, standards, market research), the research has a Japanese context (government statistics, case law, patents, domestic academic or corporate information), or an open-access alternative might exist |
| `references/mom_test.md` | Phase 1 — the task involves designing or evaluating an interview script, or the deliverable will be acted on by talking to humans |
| `references/lead_playbook.md` | Degraded mode (no `Agent` tool) or judging Worker output — failure-mode table and full fetch-failure recipe |
| `references/methodology_basis.md` | Only when verifying or updating this skill's own methodology citations |
