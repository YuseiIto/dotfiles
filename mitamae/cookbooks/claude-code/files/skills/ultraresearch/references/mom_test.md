# Mom Test vs Reference Interview — which framing applies

Cross-reference between the two interview traditions this skill draws from.
Load when designing or evaluating an interview script, or when the deliverable
will be acted on by interviewing humans. For everyday research the RI-derived
protocol in `references/interview.md` is enough.

## Triage: which framing dominates

1. **What does the user do with the answer?**
   - Read / cite / decide with it → RI.
   - Design questions for other humans → RI, plus Mom Test audit of the script.
   - Validate a belief about people → Mom Test dominates.
2. **Is the destination knowledge, or a decision about people's future behavior?**
   - Knowledge → RI. Future behavior → Mom Test (people are bad oracles about themselves).
3. **Does the deliverable include questions the user will ask someone else?**
   - Yes → audit them against the Mom Test rules below before shipping. No → RI suffices.

An LLM agent is structurally in the RI role — delivering an answer, not
validating an idea. When in doubt, default to RI.

## Essential divergence

| Axis | Reference Interview | The Mom Test |
|---|---|---|
| Asker's role | Answer provider (satisfy an information need) | Learner (find out if a belief is false) |
| Question subject | The user's information need (situation/gap/use) | The interviewee's life and past behavior — never the asker's idea |
| Closed questions | Allowed at the refinement stage | Avoided — closed framing leaks the hypothesis |
| Future-tense questions | Permitted as a use probe | Avoided — "would you buy it" is the canonical anti-pattern |
| Stop condition | Need met and user confirms | Enough evidence to advance or kill the hypothesis |

## When Mom Test rules dominate

Switch (or layer on top of RI) when any: you design or critique a script the
user will run on other humans; the task is hypothesis validation ("is X a real
problem") rather than fact-finding; product-discovery / customer-development
where the destination is a build decision; or the interviewee has an incentive
to perform (hiring, qualitative research, due diligence). Then:

- **Past behavior > future intent** — "tell me about the last time you did X".
- **Specifics > generics** — "how long did that take last week?".
- **Their world > your idea** — no pitching until they describe the problem in their own words.
- **Compliments are noise** — social warmth, not willingness to use or pay.
- **Silence is a tool** — pause after partial answers; people fill in the self-edited part.

RI rules (no leading questions, mirror vocabulary, paraphrase to verify) still
apply; Mom Test rules sit on top, not instead. Outside these contexts they are
counterproductive: pure fact-finding needs the closed refinement questions and
use probes that Mom Test forbids.

Shared anti-patterns live in `references/interview.md` ("Pitfalls to avoid").
Source: Rob Fitzpatrick, *The Mom Test*.
