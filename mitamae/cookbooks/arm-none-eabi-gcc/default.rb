if node[:platform] == 'darwin'
  package 'arm-none-eabi-gcc'
else
  unsupported_platform! node[:platform]
end
