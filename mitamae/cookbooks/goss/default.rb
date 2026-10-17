# renovate: datasource=github-releases depName=goss-org/goss extractVersion=^v(?<version>.+)$
goss_version = '0.4.10'
# Since v0.4.10 upstream releases through GoReleaser, which ships tarballs that
# spell amd64 as x86_64 instead of the former raw goss-<os>-<arch> binaries.
goss_arch = node[:os_arch] == 'arm64' ? 'arm64' : 'x86_64'

if node[:platform] == 'darwin'
  # renovate: datasource=github-release-attachments depName=goss-org/goss
  goss_darwin_arm64_sha256 = 'v0.4.10@3e5b0ff38ef1b005ee8c5e048cf8d44d700ae7529628f210bd60bff2adaf3e34'
  # renovate: datasource=github-release-attachments depName=goss-org/goss
  goss_darwin_x86_64_sha256 = 'v0.4.10@71d12ae057a929d278146ba38ca80aa1cf7159daf055d1b0065e49bb7f5d6b4a'
  goss_sha256 = ReleasePin.sha256(goss_arch == 'arm64' ? goss_darwin_arm64_sha256 : goss_darwin_x86_64_sha256,
                                  "goss darwin-#{goss_arch}")

  goss_archive = "goss_#{goss_version}_darwin_#{goss_arch}.tar.gz"

  # macOS provisioning runs unprivileged, so this path shells out to sudo for
  # the /usr/local/bin write and cannot use the github_release_binary helper
  # (which installs as the root user on Debian/Ubuntu).
  execute 'install goss' do
    command <<~EOC
      set -eu
      work_dir="$(mktemp -d)"
      trap 'rm -rf "$work_dir"' EXIT
      curl -fsSL -o "$work_dir/#{goss_archive}" "https://github.com/goss-org/goss/releases/download/v#{goss_version}/#{goss_archive}"
      echo "#{goss_sha256}  $work_dir/#{goss_archive}" | shasum -a 256 -c -
      tar -xzf "$work_dir/#{goss_archive}" -C "$work_dir" goss
      sudo install -d /usr/local/bin
      sudo install -m 0755 "$work_dir/goss" /usr/local/bin/goss
    EOC
    not_if "goss --version 2>/dev/null | grep -q '#{goss_version}'"
  end
elsif %w[ubuntu debian].include?(node[:platform])
  github_release_binary 'goss' do
    repo 'goss-org/goss'
    version goss_version
    arm64_name "goss_#{goss_version}_linux_arm64.tar.gz"
    x86_64_name "goss_#{goss_version}_linux_x86_64.tar.gz"
    # renovate: datasource=github-release-attachments depName=goss-org/goss
    arm64_sha256 'v0.4.10@90a59612b4d67d9f1a9038634c000790136bb82526a69de1e81ac075c2f6d2c6'
    # renovate: datasource=github-release-attachments depName=goss-org/goss
    x86_64_sha256 'v0.4.10@26e365428946294bcec0c61d867bb3c8349f39feb3d0e6f59084e98632785cc7'
    not_if "goss --version 2>/dev/null | grep -q '#{goss_version}'"
  end
else
  unsupported_platform! node[:platform]
end
