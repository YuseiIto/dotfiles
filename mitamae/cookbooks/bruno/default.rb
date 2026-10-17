if node[:platform] == 'darwin'
  brew_cask 'bruno'
else
  unsupported_platform! node[:platform]
end
