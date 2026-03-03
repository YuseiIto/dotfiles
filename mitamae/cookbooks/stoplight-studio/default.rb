if node[:platform] == "darwin"
  execute "install stoplight-studio via homebrew cask" do
    command "brew install --cask stoplight-studio"
    not_if "brew list --cask stoplight-studio"
  end
end
