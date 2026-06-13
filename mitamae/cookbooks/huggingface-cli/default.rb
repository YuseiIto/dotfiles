if node[:platform] == 'darwin'
  package 'huggingface-cli'
elsif %w[ubuntu debian].include?(node[:platform])
  uv_tool_package 'hf'
else
  unsupported_platform! node[:platform]
end
