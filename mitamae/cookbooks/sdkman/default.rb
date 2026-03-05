if %w[ubuntu debian].include?(node[:platform])
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

  # Enable auto-answer so `sdk install` never blocks on prompts
  execute 'Enable sdkman_auto_answer' do
    command "sed -i 's/sdkman_auto_answer=false/sdkman_auto_answer=true/' #{sdkman_dir}/etc/config"
    only_if "grep -q 'sdkman_auto_answer=false' #{sdkman_dir}/etc/config"
  end

end
