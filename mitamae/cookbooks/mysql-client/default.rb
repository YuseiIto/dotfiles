if node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "default-mysql-client" do
    user "root"
  end
elsif node[:platform] == "darwin"
  package "mysql-client"
end
