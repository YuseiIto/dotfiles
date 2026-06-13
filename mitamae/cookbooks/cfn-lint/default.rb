if node[:platform] == 'darwin'
  package 'cfn-lint'
elsif %w[ubuntu debian].include?(node[:platform])
  uv_tool_package 'cfn-lint'
else
  unsupported_platform! node[:platform]
end
