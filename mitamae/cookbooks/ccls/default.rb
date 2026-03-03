# Install ccls - C/C++/ObjC language server
if node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "ccls" do
    user "root"
  end
elsif node[:platform] == "darwin"
  package "ccls"
end
