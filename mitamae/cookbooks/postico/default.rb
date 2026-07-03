if node[:platform] == 'darwin'
  brew_cask 'postico'
else
  unsupported_platform! node[:platform]
end
