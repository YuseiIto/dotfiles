# Install the skills CLI
npm_global_package 'skills'

# Skill sources: { github_source => first_skill_name_as_install_marker }
# Add new entries here to provision more skills at install time.
# Actual SKILL.md files are NOT stored in this repo — they are fetched on demand.
skill_sources = {
  'vercel-labs/agent-skills' => 'react-best-practices',
  'squirrelscan/skills' => 'audit-website',
  'ibelick/ui-skills' => 'baseline-ui',
  'phuryn/pm-skills' => 'draft-nda',
  'obra/superpowers' => 'brainstorming'
}

skill_sources.each do |source, marker|
  execute "Install agent skills from #{source}" do
    command "skills add #{source} --global --all -y"
    not_if "test -d #{ENV['HOME']}/.claude/skills/#{marker}"
  end
end
