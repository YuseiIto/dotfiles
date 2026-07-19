# Cookbook-local: symlink a file or directory under ~/.claude
define :claude_dotfile, source: nil, cookbook_dir: nil do
  source_file = params[:source] || params[:name]
  dir = params[:cookbook_dir]
  claude_dir = File.join(ENV['HOME'], '.claude')

  directory claude_dir

  link File.join(claude_dir, params[:name]) do
    to File.join(dir, 'files', source_file)
    force true
  end
end

# Use "latest" to always install the latest version of claude-code to get the latest models and features.
# This may degrade stability, but it's the nature of the rapidly evolving AI ecosystem.
if node[:platform] == 'darwin'
  brew_cask 'claude-code@latest'
elsif %w[ubuntu debian].include?(node[:platform])
  execute 'install claude-code via official installer' do
    command 'curl -fsSL https://claude.ai/install.sh | bash -s latest'
    not_if 'command -v claude'
  end
else
  unsupported_platform! node[:platform]
end

%w[settings.json statusline-command.sh skills claude-tmux-notify CLAUDE.md rules claude-stop-review-reminder claude-mark-edit].each do |entry|
  claude_dotfile entry do
    cookbook_dir File.dirname(__FILE__)
  end
end
