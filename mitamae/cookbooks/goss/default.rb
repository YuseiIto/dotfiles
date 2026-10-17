goss_version = '0.4.10'
# Since v0.4.10 upstream releases through GoReleaser, which ships tarballs that
# spell amd64 as x86_64 instead of the former raw goss-<os>-<arch> binaries.
goss_arch = node[:os_arch] == 'arm64' ? 'arm64' : 'x86_64'

if node[:platform] == 'darwin'
  # macOS provisioning runs unprivileged, so this path shells out to sudo for
  # the /usr/local/bin write and cannot use the github_release_binary helper
  # (which installs as the root user on Debian/Ubuntu).
  execute 'install goss' do
    command <<~EOC
      set -e
      sudo mkdir -p /usr/local/bin
      curl -fsSL "https://github.com/goss-org/goss/releases/download/v#{goss_version}/goss_#{goss_version}_darwin_#{goss_arch}.tar.gz" \
        | sudo tar -xzf - -C /usr/local/bin goss
    EOC
    not_if "goss --version 2>/dev/null | grep -q '#{goss_version}'"
  end
elsif %w[ubuntu debian].include?(node[:platform])
  github_release_binary 'goss' do
    repo 'goss-org/goss'
    version goss_version
    arm64_name "goss_#{goss_version}_linux_arm64.tar.gz"
    x86_64_name "goss_#{goss_version}_linux_x86_64.tar.gz"
    not_if "goss --version 2>/dev/null | grep -q '#{goss_version}'"
  end
else
  unsupported_platform! node[:platform]
end
