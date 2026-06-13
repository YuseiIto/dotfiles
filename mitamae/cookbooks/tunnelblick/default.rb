if node[:platform] == 'darwin'
  brew_cask 'tunnelblick'
else
  unsupported_platform! node[:platform]
end
