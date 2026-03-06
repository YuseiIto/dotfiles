if node[:platform] == 'darwin'
  package 'starship'
elsif %w[ubuntu debian].include?(node[:platform])
  execute 'Install starship via official installer' do
    command 'curl -fsSL https://starship.rs/install.sh | sh -s -- --yes'
    user 'root'
    not_if 'command -v starship'
  end
end
