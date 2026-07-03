if node[:platform] == 'darwin'
  brew_cask 'affinity'
else
  unsupported_platform! node[:platform]
end
