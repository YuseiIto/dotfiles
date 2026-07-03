# System utilities, file management, remote access
if node[:platform] == 'darwin'
  casks = %w[
    alfred
    appcleaner
    cyberduck
    keyboard-cleaner
    keycastr
    onyx
    utm
    vnc-viewer
    zap
  ]

  casks.each do |cask|
    brew_cask cask
  end
else
  unsupported_platform! node[:platform]
end
