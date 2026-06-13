if node[:platform] == 'darwin'
  package 'platformio'
elsif %w[ubuntu debian].include?(node[:platform])
  uv_tool_package 'platformio' do
    bin_name 'pio'
  end
else
  unsupported_platform! node[:platform]
end
