# Writing and documentation tools
include_recipe '../drawio'

if node[:platform] == 'darwin'
  casks = %w[
    obsidian
    mactex-no-gui
  ]

  casks.each do |cask|
    brew_cask cask
  end
else
  unsupported_platform! node[:platform]
end
