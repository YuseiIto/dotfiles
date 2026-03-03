if node[:platform] == "darwin"
  package "cfn-lint"
elsif node[:platform] == "ubuntu" || node[:platform] == "debian"
  execute "Install cfn-lint via pipx" do
    command "pipx install cfn-lint"
    not_if "command -v cfn-lint"
  end
end
