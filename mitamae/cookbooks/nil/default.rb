if node[:platform] == 'darwin'
  package 'nil'
elsif %w[ubuntu debian].include?(node[:platform])
  # nil is mostly distributed via nix or rust, but let's assume binary or cargo
  execute 'Install nil via cargo' do
    command 'cargo install nil'
    not_if 'command -v nil'
  end
end
