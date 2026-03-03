if node[:platform] == "darwin"
  package "huggingface-cli"
elsif node[:platform] == "ubuntu" || node[:platform] == "debian"
  execute "Install huggingface-cli via official installer" do
    command "curl -LsSf https://hf.co/cli/install.sh | bash"
    not_if "command -v huggingface-cli"
  end
end
