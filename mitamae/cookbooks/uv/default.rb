if node[:platform] == "darwin"
  package "uv"
elsif node[:platform] == "ubuntu" || node[:platform] == "debian"
  execute "Install uv" do
    command "curl -LsSf https://astral.sh/uv/install.sh | sh"
    not_if "command -v uv"
  end
end
