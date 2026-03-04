if node[:platform] == 'darwin'
  package 'tomoyanonymous/homebrew-flatcam/flatcam-evo'
else
  MItamae.logger.error "unsupported platform #{node[:platform]}: #{__FILE__}:#{__LINE__}"
  exit 1
end
