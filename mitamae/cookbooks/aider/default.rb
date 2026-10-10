if node[:platform] == 'darwin'
  package 'aider'
elsif %w[ubuntu debian].include?(node[:platform])
  # The installer resolves aider's large dependency tree from PyPI, which
  # regularly dies on transient download failures (connection reset / broken
  # pipe mid-download) during CI image builds. Retry before failing the build.
  retriable_command 'Install aider via official installer' do
    command 'curl -fsSL https://aider.chat/install.sh | sh'
    not_if 'command -v aider'
  end
else
  unsupported_platform! node[:platform]
end
