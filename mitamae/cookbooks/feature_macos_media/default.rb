# Media creation and playback
if node[:platform] == "darwin"
  casks = %w[
    obs
    vlc
    krita
  ]

  casks.each do |cask|
    execute "install #{cask} via homebrew cask" do
      command "brew install --cask #{cask}"
      not_if "brew list --cask #{cask}"
    end
  end
end
