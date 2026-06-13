if node[:platform] == 'darwin'
  brew_cask 'slack'
else
  unsupported_platform! node[:platform]
end
