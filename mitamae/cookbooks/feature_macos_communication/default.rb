# Chat and communication
include_recipe '../slack'

if node[:platform] == 'darwin'
  casks = %w[
    discord
    keybase
  ]

  casks.each do |cask|
    brew_cask cask
  end
end
