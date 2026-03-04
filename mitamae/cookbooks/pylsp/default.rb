if node[:platform] == 'darwin'
  package 'python-lsp-server'
elsif %w[ubuntu debian].include?(node[:platform])
  uv_tool_package 'python-lsp-server', bin_name: 'pylsp'
end
