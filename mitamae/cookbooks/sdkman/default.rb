
if ['ubuntu', 'debian'].include?(node[:platform])
  home = ENV['HOME']
  sdkman_dir = "#{home}/.sdkman"

  # Dependencies for SDKMAN! and Java-based tools
  package 'zip' do
    user 'root'
  end

  package 'unzip' do
    user 'root'
  end

  # Install SDKMAN!
  execute 'Install SDKMAN!' do
    command "curl -s 'https://get.sdkman.io' | bash"
    not_if "test -d #{sdkman_dir}"
  end

  # NOTE: Shell initialization is handled via .zshrc updates or similar.
  # For immediate use in subsequent commands within the same shell:
  # . "$HOME/.sdkman/bin/sdkman-init.sh"
end
