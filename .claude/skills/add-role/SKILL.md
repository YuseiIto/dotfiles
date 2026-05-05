---
name: dotfiles-add-role
description: >
  Create a new mitamae role for a specific host machine or container in this dotfiles repository.
  Use this skill when the user says things like "add a role for new PC/machine/server", "create a role
  for [machine name]", "set up dotfiles for new computer", "configure a new host", or when a new machine
  needs its own provisioning configuration. Also trigger when the user mentions setting up a new macOS
  machine or Linux server with a specific purpose.
---

# Add a New Mitamae Role

A role defines **which cookbooks are installed on a specific host**. Each role is a standalone file (or
a small directory with a goss.yaml) that lists `include_recipe` calls and sets node attributes.

Before writing anything, fully understand the new role's scope through the steps below.

---

## Phase 1: Read existing state

Read these files to orient yourself before asking questions:

- `mitamae/roles/` — existing roles and their structure
- `docs/VARIANTS.md` — what each variant means (plum/bamboo/pine)
- `mitamae/roles/belle/default.rb` — the canonical standalone macOS role (useful as reference for new macOS roles)
- `mitamae/roles/belle/goss.yaml` — goss pattern for a full macOS role

Also list `mitamae/cookbooks/` so you know what cookbooks are available.

---

## Phase 2: Interview the user

Ask all the questions you still need answered after reading the existing state. Typical questions:

1. **Role name** — any preference? (Existing roles use plant/flower names for containers; PC roles can be anything)
2. **Platform** — macOS or Debian/Ubuntu Linux?
3. **Use case** — what is this machine for? (primary dev machine, build server, minimal VPS, etc.)
4. **Base configuration** — should it inherit from an existing role (`include_recipe '../bamboo'` etc.), or be standalone like `belle`?
5. **Tool categories to include** — walk through major groups: shell/terminal, cloud/DevOps, AI tools, LSPs, GUI apps (macOS), etc.
6. **Anything to explicitly exclude** — e.g., hardware tools, personal tools, heavy runtimes

For a **macOS standalone role**, use `belle` as the reference and ask what to add/remove relative to it.
For a **container role**, check whether inheriting from `plum` or `bamboo` covers the base.

Keep the interview concise — if the use case is clear, make reasonable assumptions and state them.

---

## Phase 3: Research & prerequisite check

Before planning, identify if any existing cookbook needs to be **refactored** to allow the new role to
use only part of it. Common case: a feature cookbook bundles multiple apps (e.g., `feature_macos_communication`
bundles Slack + Discord + Keybase) and the new role wants only one of them.

If a refactor is needed:
- Propose splitting the relevant app into its own cookbook
- This becomes Task 1 in the plan (must happen before the role file can reference it)

Also check: do any of the desired tools lack a cookbook entirely? If so, note that a cookbook must be
created first (using the `dotfiles-add-cookbook` skill) — but don't do it inline in this skill.
Flag it to the user and agree on scope before proceeding.

---

## Phase 4: Enter Plan Mode

Once you have all the information, enter plan mode with `EnterPlanMode`.

In plan mode, lay out the implementation as numbered tasks. For each task, show:
- **What** is being created or modified (exact file paths)
- **The full content** of each new file, or the exact diff for modifications

Typical task order:
1. Any prerequisite cookbook splits/refactors (if needed)
2. `mitamae/roles/<name>/default.rb` — the role file
3. `mitamae/roles/<name>/goss.yaml` — the health check file

For `default.rb`, structure the `include_recipe` calls in clearly commented sections:
```
# Infrastructure
# Shell & Terminal
# Networking
# Cloud & DevOps
# AI & Coding Assistants
# Languages & Runtimes
# Development Tools & LSPs
# macOS GUI (if darwin-only role)
```

For `goss.yaml`:
- Only include cookbooks that **have** a `goss.yaml` (check `mitamae/cookbooks/<name>/goss.yaml` exists)
- GUI-only brew_cask cookbooks (no CLI binary) typically don't have goss.yaml — omit them
- Use `../../cookbooks/<name>/goss.yaml: {}` format

Set node attributes at the top of `default.rb`:
```ruby
node.reverse_merge!(
  variant: '<role-name>',
  is_container: false,  # true for Docker/container roles
  editor_features: {
    lsp: true,
    basic_amenities: true,
    lazygit: true,
    rust_dev: true,
    prisma_dev: true,
    render_md: true,
    ai: true,
    rich_presence: true
  }
)
```

Exit plan mode (`ExitPlanMode`) and wait for the user to confirm before proceeding.

---

## Phase 5: Execute

Implement the tasks in order. For each file:
1. Create or edit the file using the Write or Edit tool
2. After creating/modifying Ruby files, run: `cd mitamae && bundle exec rubocop <path>`
3. Fix any rubocop offenses before moving to the next task

Commit after each logical unit of work:
- Cookbook splits: `git commit -m "refactor: extract <name> into its own cookbook"`
- New role: `git commit -m "feat: add <name> role for <short description>"`

---

## Phase 6: Final verification

Run rubocop across all changed files:

```bash
cd mitamae && bundle exec rubocop
```

Confirm that every cookbook referenced by `include_recipe` in the role's `default.rb` actually exists
under `mitamae/cookbooks/`. And every cookbook listed in `goss.yaml` has a corresponding `goss.yaml`
file under `mitamae/cookbooks/<name>/goss.yaml`.

---

## Checklist before finishing

- [ ] `default.rb` sets `node.reverse_merge!` with correct `variant` and `is_container`
- [ ] Every `include_recipe` path points to an existing cookbook
- [ ] `goss.yaml` only lists cookbooks that have a goss file (check each one)
- [ ] Any prerequisite cookbook refactors are committed separately
- [ ] rubocop passes with no offenses
- [ ] All commits use descriptive messages in the `feat:` / `refactor:` convention
