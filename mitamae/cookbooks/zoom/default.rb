if node[:platform] == 'darwin'
  brew_cask 'zoom'
else
  unsupported_platform! node[:platform]
end
