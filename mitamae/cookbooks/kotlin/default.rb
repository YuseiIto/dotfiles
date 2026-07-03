if node[:platform] == 'darwin'
  package 'kotlin'
elsif %w[ubuntu debian].include?(node[:platform])
  include_recipe '../sdkman'
  include_recipe '../java'

  home = ENV['HOME']

  execute 'Install Kotlin via sdkman' do
    command "bash -c 'source #{home}/.sdkman/bin/sdkman-init.sh && sdk install kotlin'"
    # sdkman installs into ~/.sdkman/candidates which is not on PATH during the
    # mitamae run, so `command -v kotlin` would never short-circuit. Test the
    # installed binary directly so the install only runs once.
    not_if "test -x #{home}/.sdkman/candidates/kotlin/current/bin/kotlin"
  end
else
  unsupported_platform! node[:platform]
end
