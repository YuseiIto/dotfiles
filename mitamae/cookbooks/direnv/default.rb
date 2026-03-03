# Install direnv - directory-level environment variable loader
if node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "direnv" do
    user "root"
  end
elsif node[:platform] == "darwin"
  package "direnv"
end
