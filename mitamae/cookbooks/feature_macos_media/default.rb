# Media creation and playback
if node[:platform] == 'darwin'
  casks = %w[
    obs
    vlc
    krita
  ]

  casks.each do |cask|
    brew_cask cask
  end
end
