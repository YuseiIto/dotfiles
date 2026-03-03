if node[:platform] == "darwin"
  package "aider"
elsif node[:platform] == "ubuntu" || node[:platform] == "debian"
  execute "Install aider via official installer" do
    command "curl -fsSL https://aider.chat/install.sh | sh"
    not_if "command -v aider"
  end
end
