if node[:platform] == "darwin"
  execute "install kicad via homebrew cask" do
    command "brew install --cask kicad"
    not_if "brew list --cask kicad"
  end
elsif node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "kicad" do
    user "root"
  end
end
