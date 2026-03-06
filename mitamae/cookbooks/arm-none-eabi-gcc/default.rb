if node[:platform] == 'darwin'
  package 'arm-none-eabi-gcc'
else
  Mitamae.logger.error "unsupported platform #{node[:platform]}: #{__FILE__}:#{__LINE__}"
  exit 1
end
