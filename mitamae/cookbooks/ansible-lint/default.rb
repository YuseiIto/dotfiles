if node[:platform] == 'darwin'
  package 'ansible-lint'
elsif %w[ubuntu debian].include?(node[:platform])
  uv_tool_package 'ansible-lint'
end
