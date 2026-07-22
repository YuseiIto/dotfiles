goss_version = '0.4.9'
goss_arch = node[:os_arch] == 'arm64' ? 'arm64' : 'amd64'

if node[:platform] == 'darwin'
  # macOS provisioning runs unprivileged, so this path shells out to sudo for
  # the /usr/local/bin write and cannot use the github_release_binary helper
  # (which installs as the root user on Debian/Ubuntu).
  execute 'install goss' do
    command <<~EOC
      set -e
      sudo curl -fsSL --create-dirs "https://github.com/goss-org/goss/releases/download/v#{goss_version}/goss-darwin-#{goss_arch}" \
        -o /usr/local/bin/goss
      sudo chmod +x /usr/local/bin/goss
    EOC
    not_if "goss --version 2>/dev/null | grep -q '#{goss_version}'"
  end
elsif %w[ubuntu debian].include?(node[:platform])
  github_release_binary 'goss' do
    repo 'goss-org/goss'
    version goss_version
    arm64_name 'goss-linux-arm64'
    x86_64_name 'goss-linux-amd64'
    not_if "goss --version 2>/dev/null | grep -q '#{goss_version}'"
  end
else
  unsupported_platform! node[:platform]
end
