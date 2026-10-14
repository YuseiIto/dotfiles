if node[:platform] == 'darwin'
  brew_cask 'typora'
else
  unsupported_platform! node[:platform]
end
