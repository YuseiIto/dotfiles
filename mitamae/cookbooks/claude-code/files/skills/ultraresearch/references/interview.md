# Reference Interview for AI Research Agents

Adapted from library & information science: RUSA *Guidelines for Behavioral
Performance of Reference and Information Service Providers* (2023 revision;
6 sections: inclusion, approachability, engagement, searching, evaluation,
closure), Robert Taylor's four levels of need (visceral → conscious →
formalized → compromised, 1968), Brenda Dervin's **Sense-Making**
(situation–gap–use) and the **neutral-questioning** technique
(Dervin & Dewdney, 1986), and Carol Kuhlthau's **ISP** uncertainty
principle (uncertainty is highest at the start and *increases* again in
the exploration stage — the "dip in confidence" that marks her *zone of
intervention*). The decision of *when* the system takes the initiative
descends from Horvitz's *Principles of Mixed-Initiative User Interfaces*
(CHI 1999). IR/NLP work on clarifying questions (Aliannejadi et al.,
SIGIR 2019; Zamani et al., WWW 2020 — a large-scale production search
deployment reported +48% CTR with clarification panes) confirms a single
well-targeted clarifying question often outperforms a longer guess.

**Core insight**: the user's *first prompt* is Taylor's "compromised
need" (Q4) — already squeezed through what they think the system can do.
Your job is to walk back toward the *formalized* (Q3) and ideally the
*conscious* (Q2) need without projecting your own frame. Taylor's
highest-payoff lever (filter 2, *objective and motivation*): "**Inquirers
frequently cannot define what they want, but they can discuss *why* they
need it**" (Taylor 1968, p.185). When in doubt about which question to
ask, ask about *use* before asking about *what*.

---

## When to interview vs. when to just go

This is a mixed-initiative decision (Horvitz 1999): the cost of asking
vs. the cost of being wrong. Use the stakes-based rule, not a gut check.

**Skip the interview and start researching** when **all** are true:
- The query is a single, unambiguous fact lookup OR multiple plausible
  intents converge on substantially the same answer.
- Output format is obvious (one sentence, one number, one snippet).
- The action is reversible and cheap to re-do — typically pure retrieval
  / read-only research with low stakes.

**Run the interview** when **any** are true:
- Multiple plausible user intents diverge to materially different answers.
- The action is irreversible, expensive, or high-stakes (procurement
  recommendations, hiring/legal/medical, production migrations, "should
  we adopt X").
- Scope, deliverable shape, or deadline are unstated and would change
  the plan.

**Cap at 3 questions, batched in one turn.** More than 3 reads as
interrogation; fewer than 1 risks Taylor's compromised-need trap.

Agent-design schools differ on this: one camp treats clarification as a
first-class agent action; another prefers "cover all plausible intents
with breadth and depth" and never asks. Both can be right — the stakes
rule above is the principled bridge: low-cost retrieval → assumption +
breadth wins; high-stakes / irreversible → one well-targeted
clarification round wins. Don't apply either policy blindly.

**Persistent project context does not pre-fill the interview.** Even when
project memory, config files, or repo conventions plausibly fix a
dimension (stack, deliverable language, paywall tolerance), still confirm
rather than silently assume. Users ask generic questions inside specific
repos all the time, and silent projection violates neutral-questioning.
The lightest form is a one-line confirmation embedded in the interview
reply: *"I'll assume {X} based on your project context — say so if
that's wrong."*

---

## The 5 dimensions to confirm (pick the gaps, don't ask all)

For each, ask only if you genuinely cannot infer the answer from the prompt.

### 1. Real need vs. stated request (Taylor / Dervin)
Dervin's Sense-Making decomposes this into three orthogonal probes —
*situation* (the context that produced the question), *gap* (what the user
cannot bridge on their own), *use* (what they will do with the answer).
Pick the one that most changes the plan. If you can only fit one
question, **prefer the *use* probe** — it covers the most ground because
users can usually articulate *why* even when they cannot articulate
*what* (Taylor 1968, filter 2).

**Use** (highest priority — recovers Q2/Q3 from Q4 most reliably):
- EN: "How will you use the answer — what decision or artefact does this feed into?"
- JA: 「この回答を何に使いますか?どんな判断や成果物につながりますか?」
- EN: "If you could have *exactly* the help you want, what would it look like?"
- JA: 「ぴったり欲しい助けが手に入るとしたら、どんな形ですか?」

**Situation** (when the trigger is unclear):
- EN: "What's the situation that prompted this — how did this question come up?"
- JA: 「この質問が出てきた背景を教えてください。何がきっかけでしたか?」

**Gap** (when the user signals confusion, not curiosity):
- EN: "What's stopping you right now — where did you get stuck?"
- JA: 「いま何が分からなくて止まっていますか?」

**Avoid asking *why* directly** — it sounds judgmental (Ross & Dewdney).
Reframe as a situation probe: *"How did this come up?"* ≠ *"Why do you
want this?"*

### 2. Scope — depth, breadth, recency, exhaustiveness
- EN: "Do you want a quick orientation, or an exhaustive deep-dive?"
- JA: 「ざっくり全体像で十分ですか、それとも網羅的に深掘りしますか？」
- EN: "How recent must sources be? (last 6 months / 2 years / all-time classics OK?)"
- JA: 「ソースの新しさの基準は？(直近半年/2年以内/古典でも可)」
- EN: "Any angles explicitly out of scope?"
- JA: 「明示的に対象外にしたい論点はありますか？」

### 3. Prior knowledge & constraints (avoid re-explaining)
- EN: "What have you already read or ruled out? Any sources you trust or distrust?"
- JA: 「すでに読んだもの・除外したいものはありますか？信頼/不信のソース源は？」
- EN: "Are there hard constraints — language, region, license, paywall tolerance?"
- JA: 「言語・地域・ライセンス・有料記事の可否などの制約は？」

### 4. Deliverable shape & decision use
- EN: "What form helps you most — short answer, comparison table, ranked list, decision memo, or annotated bibliography?"
- JA: 「成果物の形は？短答/比較表/ランキング/意思決定メモ/注釈付き文献リスト」
- EN: "Is this informing a decision, a document, or just curiosity? Who else will read it?"
- JA: 「意思決定用？ドキュメント素材？個人の好奇心？読み手は他にいますか？」

### 5. Time & confidence budget
- EN: "What's your deadline, and how much uncertainty can you tolerate in the answer?"
- JA: 「期限と、許容できる不確実性の度合いは？」

---

## Neutral-questioning rules (Dervin & Dewdney)

- **Open, not closed.** "Tell me more about X" beats "Is it X?".
- **No leading.** Don't smuggle your hypothesis into the question.
- **Mirror their vocabulary.** Reuse the user's own terms verbatim before
  introducing your own — premature reframing is the #1 way to drift off-need.
- **Acknowledge then probe.** "I can see this is about X — to make sure I get
  the right slice, …"
- **One main probe per turn.** Closed-question barrages ("playing 20
  questions" — Ross & Dewdney) trigger interrogation feel; bundle
  sub-questions inside one `AskUserQuestion` form instead of multiple
  turns.

## Verification protocol (the two-stage check)

Adapted from the intake-sheet method of the NDL International Library of
Children's Literature — the most actionable reference-interview
verification ritual in the literature, and a direct counter to Taylor's
compromised-need trap.

1. **Stage 1 — free narration.** Let the user state the request fully
   without interrupting; capture all surfaced details into your internal
   plan (the 5 dimensions). **Don't ask follow-ups yet.**
2. **Stage 2 — full-item paraphrase + re-question.** Restate every
   captured item back to the user from the top of your notes, in your
   own words, and re-ask any item from a different angle to raise
   precision. The restatement also lets the user *see* what you heard,
   which surfaces silent misreads.

Two recording rules from the same source — apply them to your internal
notes too:

- **Don't fill gaps with inference.** If the user did not say something,
  do not write it down as if they did.
- **Record ambiguous information as ambiguous.** Don't sharpen "recent"
  into "last 6 months" without confirming. Carry the fuzz forward; the
  user resolves it, not you.

Verification template (paste pattern; render in the conversation
language — English first, Japanese equivalent below):

> Here is what I've captured so far. Tell me anything that's wrong or
> missing:
> - Purpose / use: {restate}
> - Scope: {restate, with explicit ambiguity markers}
> - Format: {restate}
> - Constraints: {restate}

> ここまでで把握した内容を読み上げます。違うところ・足したいところがあれば
> 教えてください:
> - 目的/用途: {restate}
> - 範囲: {restate, with explicit ambiguity markers}
> - 形式: {restate}
> - 制約: {restate}

## Reduce input cost: present choices, don't ask for prose

Free-text answers are expensive for the user — typing, deciding wording,
worrying about being misunderstood. Where the answer space is small and
known, **use `AskUserQuestion` to present 2–4 options instead**. Click >
type. The tool also auto-appends "Other" so the user is never trapped.

**Convert these dimensions to choice questions by default:**

| Dimension | Good as choices | Keep as free text |
|-----------|-----------------|-------------------|
| Scope (depth) | quick orientation / mid-depth / exhaustive deep-dive | — |
| Recency window | last 6 mo / 2 yr / 5 yr / all-time OK | — |
| Deliverable shape | short answer / comparison table / ranked list / decision memo | — |
| Paywall tolerance | open only / institutional OK / will pay if needed | — |
| Decision context | informing a decision / drafting a doc / curiosity | — |
| Real need / situation | — | always free text — selection here flattens nuance |
| Prior knowledge & ruled-out sources | — | free text; varies wildly |

**One call, batched.** `AskUserQuestion` accepts up to 4 questions per
invocation, but this protocol still caps at 3 (see above). Bundle the
choice-style ones together so the user fills a single form rather than
walking through a Q&A.

**Use `preview` for visible trade-offs.** When the choice has a concrete
artefact behind it (output format, table layout, depth tradeoff), put a
small ASCII preview on each option. The user picks by *seeing*, not
imagining.

**Use `multiSelect: true`** when angles are not exclusive — e.g. "Which
of these aspects matter? (pick any)". Don't fake a single-choice when the
real shape is multi-pick.

**Pitfalls to avoid:**
- Don't manufacture false dichotomies. If your 4 options don't cover the
  real space, the "Other" escape hatch is doing all the work — that's a
  signal to use free text instead.
- The *real-need* question (dimension 1) is the one place where choices
  hurt. The whole point is to surface a frame you didn't predict; closed
  options pre-frame it for the user.
- Don't use `AskUserQuestion` to confirm your plan ("does this sound
  right?"). Plan confirmation belongs to the harness's plan-approval
  flow. Use it to *gather information you don't have*.

## Stop conditions (when 1 question is enough)

Ship the interview after **one** turn if:
- You can now state the deliverable, scope, and use in one sentence each, AND
- The remaining ambiguity is cheaper to resolve by *doing* the research than
  by asking again. (Kuhlthau: tolerate uncertainty; don't drive it to zero.)

Otherwise loop **once more, max**. Then start. Mid-research, surface
contradictions or scope surprises back to the user instead of pre-asking
every edge case.

### Re-interview triggers

Kuhlthau's ISP predicts a **dip in confidence** in the Exploration stage:
as the user encounters conflicting or inconsistent information, uncertainty
*increases* before it decreases. This is Kuhlthau's **zone of
intervention** — exactly where a short re-interview pays for itself, even
if the pre-research interview was clean.

Re-open the interview mid-research when any of these fire:

- **Contradiction surfaced** between worker findings — and resolving it
  requires knowing which side aligns with the user's *use*.
- **Scope drift detected** — the synthesis suggests an adjacent question
  that may be the user's real Q3.
- **The user signals confusion in feedback** ("hmm, that's not quite
  what I meant", "wait — is X relevant?") — treat this as the ISP dip,
  not as a complaint. Re-anchor on *use*, not on *what*.

The re-interview is one focused question, not a full restart. Bring
back the verification template (above) populated with what you now
believe, and ask the user to correct it.

## One-turn template (paste into your reply)

Render in the conversation language — English first, Japanese equivalent
below:

> Before I start, a few points that directly affect answer quality:
> 1. **Purpose / use**: What will you use these findings for?
> 2. **Scope**: Is an overview enough, or exhaustive? Any deadline?
> 3. **Format**: Short answer, comparison table, or full report?
>
> (Skip anything that doesn't apply.)

> 着手前に、回答精度に効く点だけ確認させてください:
> 1. **目的/用途**: この調査結果を何に使いますか？
> 2. **範囲**: 全体像で十分か、網羅的か。期限は？
> 3. **形式**: 短答・比較表・レポートのどれが助かりますか？
>
> （不要な項目は飛ばして大丈夫です）

## Plain-text rendering

If the harness has no `AskUserQuestion` tool, render the same questions as
plain markdown. Number the dimensions, present closed options as bullet
lists with a leading `-`, keep the real-need question as free text.
All structural rules above still apply (≤3 dimensions, batched, mirror
vocabulary, no leading, no false dichotomy). **Always include an
"Other / free text" escape hatch in choice lists** (JA: 「その他 /
自由記述」) — without it, users are trapped if your options miss their
real shape, and the closed framing flattens nuance.

Template for non-trivial fuzziness in plain text (shown in English; use
the Japanese labels below when conversing in Japanese):

```
Before I start, let me confirm {N} points. Skip any that don't apply.

**1. {real-need wording, mirrored from the user}** (free text)
{open question — what triggered this, what's the stuck point, what will
they do with the answer}

**2. {scope / recency / constraint dimension}** (pick one)
- {concrete option 1}
- {concrete option 2}
- {concrete option 3}
- Other: free text

**3. {deliverable shape / decision context}** (pick one)
- {concrete option 1}
- {concrete option 2}
- {concrete option 3}
- Other: free text
```

Japanese label equivalents: header 「着手前に、{N}点だけ確認させてください。
不要な項目は飛ばしてOK。」; (free text) = （自由記述）; (pick one) =
（いずれか）; "Other: free text" = 「その他: 自由記述」.

The free-text dimension #1 is non-negotiable — closed options for the
real-need question pre-frame what you are trying to surface.
