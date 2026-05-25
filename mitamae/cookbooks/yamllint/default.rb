if node[:platform] == 'darwin'
  package 'yamllint'
elsif %w[ubuntu debian].include?(node[:platform])
  uv_tool_package 'yamllint'
end
