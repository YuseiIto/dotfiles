if node[:platform] == 'darwin'
  brew_cask 'zotero'
else
  unsupported_platform! node[:platform]
end
