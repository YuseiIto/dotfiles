if node[:platform] == 'darwin'
  execute 'install claude-code via homebrew cask' do
    command 'brew install --cask claude-code'
    not_if 'brew list --cask claude-code'
  end
elsif node[:platform] == 'ubuntu' || node[:platform] == 'debian'
  execute 'install claude-code via official installer' do
    command 'curl -fsSL https://claude.ai/install.sh | bash'
    not_if 'command -v claude'
  end
end
