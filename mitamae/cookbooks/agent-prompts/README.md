# agent-prompts

Canonical, **tool-agnostic** agent guidance shared across every AI coding agent
(Claude Code, OpenHands, ...). This cookbook is the single source of truth; it
holds the content once and consumer cookbooks symlink it into each tool's own
config directory so the same prompts and skills stay in sync everywhere.

## Why this exists

Each agent reads its configuration from a different place
(`~/.claude/` for Claude Code, `~/.openhands/` for OpenHands, ...). Without a
shared source, the same guidance would have to be copied and maintained per
tool. Instead, the portable content lives here once and is reused.

## Contents

```
files/
├── user-preferences.md          # always-on user identity & preferences
└── skills/
    ├── coding-comments/SKILL.md  # keyword-triggered skills, SKILL.md standard
    ├── git-commits/SKILL.md
    └── parallelization/SKILL.md
```

- **`user-preferences.md`** is intentionally frontmatter-free so it reads cleanly
  as Claude Code's `CLAUDE.md` user memory and loads as an always-on agent in
  tools that treat a trigger-less document as always active.
- **`skills/<name>/SKILL.md`** follow the [SKILL.md open standard][skill-md]
  (`name` / `description` / `triggers` frontmatter). Claude Code uses
  `description` to decide when to surface a skill; OpenHands keyword-matches on
  `triggers`. Extra frontmatter keys are ignored by tools that do not use them.

## Consumers

This cookbook installs nothing on its own. It only provides the
`agent_prompt_link` helper, so it ships no `goss.yaml` — the resulting symlinks
are asserted by the cookbooks that create them:

- `claude-code` → `~/.claude/CLAUDE.md`, `~/.claude/skills`
- `openhands`   → `~/.openhands/microagents/user-preferences.md`, `~/.openhands/skills`

A consumer includes this recipe and links what it needs:

```ruby
include_recipe '../agent-prompts'

agent_prompt_link File.join(ENV['HOME'], '.openhands', 'skills') do
  source 'skills'
end
```

[skill-md]: https://docs.claude.com/en/docs/claude-code/skills
