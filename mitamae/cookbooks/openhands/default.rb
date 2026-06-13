# OpenHands user-scope configuration.
#
# OpenHands does not read Claude Code's ~/.claude config, so this cookbook wires
# the same canonical agent guidance (owned by the agent-prompts cookbook) into
# the locations OpenHands loads by default for the current user:
#   ~/.openhands/skills/        - keyword-triggered skills (SKILL.md standard)
#   ~/.openhands/microagents/   - always-on user knowledge (frontmatter optional)
# Both directories are loaded automatically by the OpenHands CLI/SDK when present.
#
# This cookbook only provisions configuration. Installing the OpenHands runtime
# itself is out of scope here — it is provided by the execution environment
# (e.g. the container image) — so there is no platform-specific install branch.

include_recipe '../agent-prompts'

openhands_dir = File.join(ENV['HOME'], '.openhands')

directory openhands_dir
directory File.join(openhands_dir, 'microagents')

# Keyword-triggered skills — the SKILL.md open standard, shared with Claude Code.
agent_prompt_link File.join(openhands_dir, 'skills') do
  source 'skills'
end

# Always-on user identity/preferences. A microagent without triggers is loaded
# into every conversation, mirroring Claude Code's CLAUDE.md user memory.
agent_prompt_link File.join(openhands_dir, 'microagents', 'user-preferences.md') do
  source 'user-preferences.md'
end
