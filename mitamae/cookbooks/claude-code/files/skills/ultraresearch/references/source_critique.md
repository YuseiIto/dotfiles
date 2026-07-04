# Source Critique Checklist (Phase 4)

Progressive-disclosure reference for the **critic pass**. Goes beyond
"does the content sound right" and audits the **metadata, provenance, and
citation graph** of every source the synthesis depends on. Once loaded,
apply it to each claim the synthesis depends on before passing it to the
user.

Synthesizes: CRAAP (Currency/Relevance/Authority/Accuracy/Purpose), SIFT
(Stop, Investigate, Find better coverage, Trace claims — Caulfield),
**lateral reading** (Wineburg / SHEG; also explicitly endorsed by **RUSA
2023 §5 Evaluation** for reference work, alongside the 9-criterion rubric
*accuracy / authority / bias / coverage / credibility / currency /
relevance / reliability / scope*), IFLA "How to Spot Fake News" (8 steps),
OSINT verification (Bellingcat handbook: source vetting, geolocation,
chronolocation, EXIF/metadata), journalism fact-checking (PolitiFact, Snopes
sourcing trees), and Wikipedia **WP:RS / WP:V** (third-party, published,
attributable).

For each item: **PASS / NEEDS-CHECK / FAIL**, plus the action on FAIL.
A claim with **any FAIL** must be downgraded to `[UNVERIFIED]` or dropped.

---

## A. Chronological consistency (timeline integrity)

1. **Publication date precedes the claim's reference window.**
   - PASS: source dated before the event/version it describes.
   - NEEDS-CHECK: undated page, or "last updated" only → fetch via
     `web.archive.org` to find first-seen date; check `<meta>` `article:published_time`,
     sitemap, or `Last-Modified` header.
   - FAIL: source predates the phenomenon it claims to describe (e.g., a
     post written before the API version it discusses was released).
     **Action**: drop, or replace with a post-event source.

2. **Currency vs. domain half-life.** APIs/security/LLM topics decay in months;
   historical/mathematical claims do not. Flag any source >12 months old on
   fast-moving topics.
   - **Action on FAIL**: re-fetch current docs; mark claim `[STALE: as-of YYYY-MM]`.

3. **Citation order is causally consistent.** A "seminal" paper must predate
   what it allegedly seeded. Check arXiv v1 dates, not journal dates.
   - **Action on FAIL**: swap to true predecessor or remove the lineage claim.

4. **Updated/retracted?** Check `retractionwatch.com`, journal errata, doc
   changelogs, GitHub release notes for breaking changes / deprecations.
   - **Action on FAIL**: cite the retraction; do not propagate the original.

## B. Domain authenticity (URL provenance)

5. **Canonical official domain.** `anthropic.com` ≠ `anthropic.ai` ≠
   `anthr0pic.com`. Verify via the org's own footer/about, WHOIS age,
   cross-link from a known-good page.
   - **Action on FAIL**: re-fetch from the canonical domain; flag look-alikes.

6. **Primary vs. syndicated/mirror.** Reuters/AP wire stories republished by
   10 outlets count as **one** source. Resolve to the originating byline/URL.
   - **Action on FAIL**: collapse duplicates in the citation graph; do not
     count syndication as independent corroboration.

7. **Archive cross-check.** For any load-bearing URL, confirm it exists in
   `web.archive.org` (Wayback) **and** that the archived version matches the
   live version (no stealth edits).
   - **Action on FAIL**: cite the Wayback snapshot URL; note the diff.

8. **HTTPS, valid cert, no typosquat / homograph (IDN) characters in the
   hostname.** Reject Cyrillic-look-alike domains.

## C. Author authority & independence

9. **Real, identifiable author** with verifiable affiliation (institutional
   page, ORCID, LinkedIn, GitHub). Anonymous = lower weight unless the
   *outlet* itself is authoritative (e.g., editorials).
   - **Action on FAIL**: downgrade to `[ANONYMOUS]`; require a second source.

10. **Domain-relevant expertise.** A cardiologist on monetary policy is not
    an authority. Match credentials to claim domain (lateral reading).

11. **Conflict of interest disclosed.** Vendor blogs about their own product,
    paid placements, sponsor disclosures, "as told to" pieces.
    - **Action on FAIL**: tag `[VENDOR-SOURCE]`; require independent corroboration.

12. **Pseudonym/handle traceable** to a consistent identity over time
    (prior posts, conference talks, code commits). One-post accounts are
    near-zero weight.

## D. Version & edition integrity

13. **Doc version pinned.** API/library claims cite a specific version
    (`v2.3.1`, commit SHA, dated docs URL). "Latest" links rot.
    - **Action on FAIL**: re-fetch with explicit version in the URL.

14. **Preprint vs. peer-reviewed.** Distinguish arXiv v1 from v3 from
    journal-accepted. Check OpenReview / journal page for status.
    - **Action on FAIL**: prefer the latest peer-reviewed version; note delta
      from preprint if material.

15. **Deprecation / breaking-change window.** Did the cited behavior change
    between source date and today? Check changelogs, migration guides.

## E. Citation-graph independence

16. **N-source rule with independence check.** "Three sources confirm" is
    only valid if the three are **causally independent** — different reporters,
    different primary observations, no shared upstream wire.
    - **Action on FAIL**: treat as a single source; demote confidence.

17. **Trace to primary.** SIFT's "T": follow every secondary claim to the
    primary document/dataset/press release/court filing. If the trail dead-ends
    at another summary, the chain is broken.
    - **Action on FAIL**: cite the primary, or mark `[SECONDARY-ONLY]`.

18. **Circular citation detection.** Source A cites B, B cites A, or both
    cite a since-retracted C. Build a 2-hop graph for any high-stakes claim.

## F. Content-level accuracy (lightweight; complements, not replaces, A–E)

19. **Quote fidelity.** The pulled `quote` actually appears in the cited URL
    and supports the `claim` literally (not just topically). Spot-check by
    re-fetch + grep.
    - **Action on FAIL**: rewrite or drop the claim.

20. **Numbers/dates match across sources.** A 23% figure in one source and
    32% in another is a contradiction, not a rounding.

21. **Image/video provenance** (when sources include media): EXIF date/GPS
    consistent with claimed time/place; reverse-image-search to detect reuse;
    geolocate landmarks against satellite imagery (Bellingcat method).

## G. Machine-generated / low-effort content heuristics

Surface tells of machine generation shift with each model generation; the
durable signals are structural — absence of primary reporting, unverifiable
authorship, and content that only restates other summaries.

22. **Low-effort content signals.** Formulaic structure and template phrasing
    with no original reporting or first-hand observation; generic stock
    imagery; empty hedging; fabricated citations; no identifiable author
    combined with a recently registered domain; suspicious publish-rate
    bursts across the site.
    - **Action on FAIL**: tag `[POSSIBLE-AI-CONTENT]`; do not use as primary
      source for any factual claim.

23. **Fabricated citation risk.** Machine-written articles routinely invent
    DOIs, arXiv IDs, and author names that *look* plausible. Resolve every
    cited DOI/arXiv ID; reject if the resolver 404s or returns an unrelated
    paper.

24. **LLM-laundered content.** A post that is itself a summary of other
    LLM summaries adds no information and amplifies hallucinations. Demand
    a primary trace (item 17).

25. **LLM nuance-flattening on complex / known-item sources.** When a
    cited source is itself an LLM-generated summary of a domain-specific,
    nuanced, or known-item topic (medical, legal, niche technical,
    bibliographic identification, locale-specific reference), expect
    *silent flattening*: distinctions the original made are collapsed
    into a confident-sounding paraphrase. LIS evaluation literature
    (Lai & Chow, *College & Research Libraries* 2024 — ChatGPT on
    reference inquiries via the READ Scale) found LLM outputs *"cannot
    detect nuances"* that human reference staff routinely catch on
    complex queries.
    - **Action on FAIL**: do not propagate the LLM summary as the
      claim. Re-trace to the primary that it claims to summarize,
      compare them, and either cite the primary or mark
      `[NUANCE-RISK: LLM-summary, primary not yet reconciled]`.
    - **Apply this same caution to your own worker summaries.** A
      worker that returned a confident paraphrase on a complex topic
      may have flattened the same way a third-party LLM source would
      have. Spot-check Phase 3 citations against the actual fetched
      page text, not against the worker's restatement of it.

---

## Critic verdict

- **PASS** — every load-bearing claim clears A–F; low-effort-content screen
  (G) passed.
- **NEEDS_IMPROVEMENT** — specific items failed; re-dispatch a worker to
  re-fetch, find independent corroboration, or pin a version.
- **FAIL** — multiple sources fail B/C/E; replan from Phase 1 with new
  source-diversity constraints.

**Default downgrade rule:** any single FAIL on A1, B5, B6, C9, E16, E17,
G22, G23, or G25 → claim becomes `[UNVERIFIED]` in the synthesis until
resolved.
