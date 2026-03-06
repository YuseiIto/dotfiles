# Fonts
if node[:platform] == 'darwin'
  casks = %w[
    font-eb-garamond
    font-hack-nerd-font
  ]

  casks.each do |cask|
    brew_cask cask
  end
end
