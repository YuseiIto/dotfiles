if node[:platform] == 'darwin'
  package 'rust'
  package 'rust-analyzer'
elsif %w[ubuntu debian].include?(node[:platform])
  execute 'Install Rust via rustup' do
    command "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    not_if 'command -v rustc'
  end
  execute 'Install rust-analyzer via rustup' do
    command 'rustup component add rust-analyzer'
    not_if 'command -v rust-analyzer'
  end
end
