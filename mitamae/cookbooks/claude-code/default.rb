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

if node[:platform] == 'darwin'
  brew_cask 'claude-code'
elsif %w[ubuntu debian].include?(node[:platform])
  execute 'install claude-code via official installer' do
    command 'curl -fsSL https://claude.ai/install.sh | bash'
    not_if 'command -v claude'
  end
end

%w[settings.json statusline-command.sh skills].each do |entry|
  claude_dotfile entry do
    cookbook_dir File.dirname(__FILE__)
  end
end
