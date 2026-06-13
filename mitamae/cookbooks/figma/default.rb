if node[:platform] == 'darwin'
  brew_cask 'figma'
else
  unsupported_platform! node[:platform]
end
