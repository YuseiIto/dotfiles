# Tool-agnostic, user-scope agent guidance shared across AI coding agents
# (Claude Code, OpenHands, ...). This cookbook owns the canonical content as a
# single source of truth; consumer cookbooks symlink it into each tool's own
# config directory so the same instructions and skills stay in sync everywhere.
#
# Layout of files/:
#   user-preferences.md     - always-on user identity/preferences (no frontmatter
#                             so it stays clean as Claude's CLAUDE.md memory and
#                             loads as an always-on agent elsewhere)
#   skills/<name>/SKILL.md   - keyword-triggered skills written in the SKILL.md
#                             open standard, understood by both Claude Code and
#                             OpenHands
#
# This cookbook installs nothing and produces no host state on its own; it only
# provides the `agent_prompt_link` helper. The observable symlinks are asserted
# in the consumer cookbooks' goss files, so this cookbook ships no goss.yaml.

# Symlink an entry from this cookbook's files/ to an absolute target path.
#
#   agent_prompt_link File.join(ENV['HOME'], '.openhands', 'skills') do
#     source 'skills'
#   end
define :agent_prompt_link, source: nil do
  files_dir = File.join(File.dirname(__FILE__), 'files')
  source_path = params[:source] || File.basename(params[:name])

  link params[:name] do
    to File.join(files_dir, source_path)
    force true
  end
end
