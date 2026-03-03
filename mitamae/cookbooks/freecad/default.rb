if node[:platform] == "darwin"
  execute "install freecad via homebrew cask" do
    command "brew install --cask freecad"
    not_if "brew list --cask freecad"
  end
elsif node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "freecad" do
    user "root"
  end
end
