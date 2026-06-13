if node[:platform] == 'darwin'
  brew_cask 'stoplight-studio'
else
  unsupported_platform! node[:platform]
end
