if node[:platform] == 'darwin'
  brew_cask 'ovice'
else
  unsupported_platform! node[:platform]
end
