# Methodology basis (provenance only — not runtime instructions)

Load this file only when verifying or updating the citations that SKILL.md's
rules rest on. Citation accuracy last verified 2026-06.

| Rule in SKILL.md | Source |
|---|---|
| Orchestrator-worker pattern; Lead never searches; simplicity-first | Anthropic, *Building Effective Agents* — <https://www.anthropic.com/engineering/building-effective-agents> |
| ~15× chat-baseline token cost; token usage explains ~80% of variance; scaling table (simple=1 Worker / comparison=2–4 / complex=10+); 4 essentials per sub-agent brief (objective, output format, tool guidance, task boundaries); single-call 0–1-score judge config; 50-subagent and vague-briefing failure modes. SKILL.md adapts the scaling table deliberately: straightforward queries exit the skill instead of using 1 Worker, and depth-first uses 3–5 Workers to support triangulation | Anthropic, *How we built our multi-agent research system* — <https://www.anthropic.com/engineering/multi-agent-research-system> |
| Compaction; structured note-taking; sub-agents return distilled summaries only; just-in-time retrieval | Anthropic, *Effective context engineering for AI agents* — <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents> |
| No critique loop without external grounding | Huang et al., *Large Language Models Cannot Self-Correct Reasoning Yet* (ICLR 2024) — <https://arxiv.org/abs/2310.01798>. Follow-ups confirm (Kamoi et al. 2024 survey; Tsui 2025). Caveat: SCoRe (ICLR 2025, <https://arxiv.org/abs/2409.12917>) shows RL-trained intrinsic self-correction — does not apply to prompt-time critique. |
| Critic as acceptance function; parallel candidates + lightweight verifier beats sequential deepening | Asymmetric verification / parallel test-time scaling (arXiv:2510.06135) — <https://arxiv.org/abs/2510.06135> |
| Reference interview (`references/interview.md`) | Taylor (1968); RUSA Behavioral Guidelines (2023); Dervin & Dewdney neutral questioning (1986); Kuhlthau ISP; Horvitz mixed-initiative (CHI 1999) |
| Never deliver a bare "couldn't find it"; closing course-correction invitation (Phase 5) | IFLA Digital Reference Guidelines; RUSA 2023 §6 |
