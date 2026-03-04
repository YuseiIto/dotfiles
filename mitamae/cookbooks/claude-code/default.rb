if node[:platform] == 'darwin'
  brew_cask 'claude-code'
elsif %w[ubuntu debian].include?(node[:platform])
  execute 'install claude-code via official installer' do
    command 'curl -fsSL https://claude.ai/install.sh | bash'
    not_if 'command -v claude'
  end
end
