# System utilities, file management, remote access
if node[:platform] == "darwin"
  casks = %w[
    alfred
    appcleaner
    cyberduck
    keyboard-cleaner
    keycastr
    onyx
    utm
    vnc-viewer
    raspberry-pi-imager
    zap
  ]

  casks.each do |cask|
    execute "install #{cask} via homebrew cask" do
      command "brew install --cask #{cask}"
      not_if "brew list --cask #{cask}"
    end
  end
end
