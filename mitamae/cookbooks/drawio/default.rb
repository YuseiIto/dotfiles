if node[:platform] == 'darwin'
  brew_cask 'drawio'
else
  unsupported_platform! node[:platform]
end
