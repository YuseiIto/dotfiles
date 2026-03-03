if node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "build-essential" do
    user "root"
  end
end
