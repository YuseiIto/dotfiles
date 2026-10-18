if node[:platform] == 'darwin'
  package 'pyrefly'
elsif %w[ubuntu debian].include?(node[:platform])
  uv_tool_package 'pyrefly'
else
  unsupported_platform! node[:platform]
end
