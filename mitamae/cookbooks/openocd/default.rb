if node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "openocd" do
    user "root"
  end
elsif node[:platform] == "darwin"
  package "open-ocd"
end
