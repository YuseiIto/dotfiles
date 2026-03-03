home = ENV['HOME']

execute 'Install Rust via rustup' do
  command "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
  not_if "test -f #{home}/.cargo/bin/rustc"
end

execute 'Install rust-analyzer via rustup' do
  command "bash -c 'source #{home}/.cargo/env && rustup component add rust-analyzer'"
  not_if "bash -c 'source #{home}/.cargo/env && rustup component list | grep -q \"rust-analyzer.*(installed)\"'"
end
