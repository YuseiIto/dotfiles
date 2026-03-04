# Writing and documentation tools
if node[:platform] == 'darwin'
  casks = %w[
    obsidian
    drawio
    mactex-no-gui
  ]

  casks.each do |cask|
    brew_cask cask
  end
end
