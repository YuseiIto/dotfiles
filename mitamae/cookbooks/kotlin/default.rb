if node[:platform] == 'darwin'
  package 'kotlin'
elsif %w[ubuntu debian].include?(node[:platform])
  include_recipe '../sdkman'
  include_recipe '../java'

  execute 'Install Kotlin via sdkman' do
    home = ENV['HOME']
    command "bash -c 'source #{home}/.sdkman/bin/sdkman-init.sh && sdk install kotlin'"
    not_if 'command -v kotlin'
  end
end
