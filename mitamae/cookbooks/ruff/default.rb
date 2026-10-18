if node[:platform] == 'darwin'
  package 'ruff'
elsif %w[ubuntu debian].include?(node[:platform])
  uv_tool_package 'ruff'
else
  unsupported_platform! node[:platform]
end
