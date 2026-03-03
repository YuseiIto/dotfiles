if node[:platform] == "darwin"
  package "kotlin"
elsif node[:platform] == "ubuntu" || node[:platform] == "debian"
  include_recipe "../sdkman"

  execute "Install Kotlin via sdkman" do
    command "bash -c 'source $HOME/.sdkman/bin/sdkman-init.sh && sdk install kotlin'"
    not_if "bash -c 'source $HOME/.sdkman/bin/sdkman-init.sh && sdk list kotlin | grep -q \"*\"'"
  end
end
