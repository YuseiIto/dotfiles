---
name: dotfiles-add-agent-skill
description: >
  Add a new agent skill source to this dotfiles repository so it is automatically installed
  at provision time. Use this skill whenever the user says things like "add X skills",
  "install skill from Y repo", "add agent skill for Z", "track this skill set in dotfiles",
  or "provision skills from X".
---

# Add a New Agent Skill Source

This dotfiles repo manages agent skills (Claude Code, OpenCode, Cursor, etc.) via
[vercel-labs/skills](https://github.com/vercel-labs/skills). Only **metadata** (source references)
is stored in this repo — actual `SKILL.md` files are fetched at provision time by `skills add`.

## How it works

```
dotfiles repo (source list only)         ~/.claude/skills/ (fetched at provision)
─────────────────────────────────        ─────────────────────────────────────────
mitamae/cookbooks/agent-skills/          react-best-practices/
  default.rb                     ──→     web-design-guidelines/
    'vercel-labs/agent-skills'           ...
    'your/new-skills-repo'
```

---

## Step 1: Find the skill source details

Fetch the target repository to identify:
- The **GitHub source** in `owner/repo` format (e.g., `vercel-labs/agent-skills`)
- The **name of at least one skill** it contains — used as an install marker in `not_if`

Skill names come from the `name:` field in each skill's `SKILL.md` frontmatter, or from the
directory name if frontmatter is absent. Fetch the repo's README or browse its `skills/` directory.

```
WebFetch https://github.com/<owner>/<repo>
→ "What skills does this repo contain? What are the skill directory names?"
```

---

## Step 2: Edit `default.rb`

File: `mitamae/cookbooks/agent-skills/default.rb`

Add one entry to the `skill_sources` hash:

```ruby
skill_sources = {
  'vercel-labs/agent-skills' => 'react-best-practices',  # existing
  'owner/new-skills-repo'    => 'first-skill-name'        # ← add this
}
```

The hash value (right side) must be the name of **any one skill** from that source.
It is used as a `not_if` guard: if `~/.claude/skills/<marker>/` exists, the source is
considered already installed and the `execute` block is skipped.

Full file for reference:

```ruby
# Install the skills CLI
npm_global_package 'skills'

# Skill sources: { github_source => first_skill_name_as_install_marker }
# Add new entries here to provision more skills at install time.
# Actual SKILL.md files are NOT stored in this repo — they are fetched on demand.
skill_sources = {
  'vercel-labs/agent-skills' => 'react-best-practices'
}

skill_sources.each do |source, marker|
  execute "Install agent skills from #{source}" do
    command "skills add #{source} --global --all -y"
    not_if "test -d #{ENV['HOME']}/.claude/skills/#{marker}"
  end
end
```

---

## Step 3: Update `goss.yaml`

File: `mitamae/cookbooks/agent-skills/goss.yaml`

Add a `file` check for the marker skill you chose:

```yaml
command:
  skills --version:
    exit-status: 0
    timeout: 5000
file:
  "{{.Env.HOME}}/.claude/skills/react-best-practices":   # existing
    exists: true
    filetype: directory
  "{{.Env.HOME}}/.claude/skills/first-skill-name":       # ← add this
    exists: true
    filetype: directory
```

---

## Checklist

- [ ] Fetched the target repo to confirm skill names
- [ ] Added entry to `skill_sources` hash in `default.rb`
- [ ] Marker skill name matches an actual skill in that source
- [ ] Added `file` check to `goss.yaml`
- [ ] Run `cd mitamae && bundle exec rubocop cookbooks/agent-skills/default.rb` — no offenses

No role changes needed — `agent-skills` cookbook is already included in `bamboo`.
