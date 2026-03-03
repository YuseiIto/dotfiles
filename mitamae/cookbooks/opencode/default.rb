if node[:platform] == 'darwin'
  package 'opencode'
elsif ['ubuntu', 'debian'].include?(node[:platform])
  execute 'Install opencode via official installer' do
    command 'curl -fsSL https://opencode.ai/install.sh | sh'
    not_if 'command -v opencode'
  end
end
