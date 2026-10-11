# Install prowler - multi-cloud security assessment, auditing, and hardening tool
if node[:platform] == 'darwin'
  package 'prowler'
elsif %w[ubuntu debian].include?(node[:platform])
  # NOTE: prowler declares requires-python <3.14, and its pydantic-core pin
  # ships no wheels for newer CPython, so uv's default interpreter fails to
  # build it from source.
  uv_tool_package 'prowler' do
    python '3.13'
  end
else
  unsupported_platform! node[:platform]
end
