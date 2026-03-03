if node[:platform] == "darwin"
  package "kotlin"
elsif node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "snapd" do
    user "root"
  end

  execute "Install Kotlin via snap" do
    command "snap install kotlin --classic"
    user "root"
    not_if "snap list | grep -q kotlin"
  end
end
