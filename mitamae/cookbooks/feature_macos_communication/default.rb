# Chat and communication
if node[:platform] == "darwin"
  casks = %w[
    slack
    discord
    keybase
  ]

  casks.each do |cask|
    execute "install #{cask} via homebrew cask" do
      command "brew install --cask #{cask}"
      not_if "brew list --cask #{cask}"
    end
  end
end
