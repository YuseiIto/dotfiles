# Chat and communication
if node[:platform] == 'darwin'
  casks = %w[
    slack
    discord
    keybase
  ]

  casks.each do |cask|
    brew_cask cask
  end
end
