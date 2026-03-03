if node[:platform] == 'darwin'
  package 'rust'
elsif node[:platform] == 'ubuntu' || node[:platform] == 'debian'
  execute 'Install Rust via rustup' do
    command "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    not_if 'command -v rustc'
  end
end
