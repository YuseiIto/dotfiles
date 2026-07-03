# Install prowler - multi-cloud security assessment, auditing, and hardening tool
if node[:platform] == 'darwin'
  package 'prowler'
elsif %w[ubuntu debian].include?(node[:platform])
  uv_tool_package 'prowler'
else
  unsupported_platform! node[:platform]
end
