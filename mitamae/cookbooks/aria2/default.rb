# Install aria2 - lightweight multi-protocol download utility
if node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "aria2" do
    user "root"
  end
elsif node[:platform] == "darwin"
  package "aria2"
end
