# Install hermes-agent - self-improving AI agent that creates skills from experience
#
# NOTE: Upstream documents a `curl | bash` installer plus a `hermes update`
# self-update command. Both are deliberately avoided so upgrades stay owned by
# the same package manager that provisions the rest of the host. The published
# binary is `hermes`, not `hermes-agent`.
if node[:platform] == 'darwin'
  package 'hermes-agent'
elsif %w[ubuntu debian].include?(node[:platform])
  uv_tool_package 'hermes-agent', bin_name: 'hermes'
else
  unsupported_platform! node[:platform]
end
