include_recipe "../../cookbooks/nodenv"

if node[:platform] == "darwin"
  package "gemini-cli"
elsif node[:platform] == "ubuntu" || node[:platform] == "debian"
  execute "Install gemini-cli via npm" do
    command "npm install -g @google/gemini-cli"
    not_if "command -v gemini"
  end
end
