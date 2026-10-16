# renovate: datasource=github-releases depName=goss-org/goss extractVersion=^v(?<version>.+)$
goss_version = '0.4.9'
goss_arch = node[:os_arch] == 'arm64' ? 'arm64' : 'amd64'

if node[:platform] == 'darwin'
  # renovate: datasource=github-release-attachments depName=goss-org/goss
  goss_darwin_arm64_sha256 = 'v0.4.9@111d2ada89f8787838d176011de2fd0cfe8959c64c2698ce28feb587337d01fc'
  # renovate: datasource=github-release-attachments depName=goss-org/goss
  goss_darwin_amd64_sha256 = 'v0.4.9@e0c1b22360ced9f5394e64244877dfe1d3488aee9de75c56b9e02ae72c3fe4ff'
  goss_sha256 = (goss_arch == 'arm64' ? goss_darwin_arm64_sha256 : goss_darwin_amd64_sha256).split('@', 2).last

  # macOS provisioning runs unprivileged, so this path shells out to sudo for
  # the /usr/local/bin write and cannot use the github_release_binary helper
  # (which installs as the root user on Debian/Ubuntu).
  execute 'install goss' do
    command <<~EOC
      set -eu
      work_dir="$(mktemp -d)"
      trap 'rm -rf "$work_dir"' EXIT
      curl -fsSL -o "$work_dir/goss" "https://github.com/goss-org/goss/releases/download/v#{goss_version}/goss-darwin-#{goss_arch}"
      echo "#{goss_sha256}  $work_dir/goss" | shasum -a 256 -c -
      sudo install -d /usr/local/bin
      sudo install -m 0755 "$work_dir/goss" /usr/local/bin/goss
    EOC
    not_if "goss --version 2>/dev/null | grep -q '#{goss_version}'"
  end
elsif %w[ubuntu debian].include?(node[:platform])
  github_release_binary 'goss' do
    repo 'goss-org/goss'
    version goss_version
    arm64_name 'goss-linux-arm64'
    x86_64_name 'goss-linux-amd64'
    # renovate: datasource=github-release-attachments depName=goss-org/goss
    arm64_sha256 'v0.4.9@14fd24ac08236559f4809e6a627792d1b947ed98654bba1662ef1d6122d77e18'
    # renovate: datasource=github-release-attachments depName=goss-org/goss
    x86_64_sha256 'v0.4.9@87dd36cfa1b8b50554e6e2ca29168272e26755b19ba5438341f7c66b36decc19'
    not_if "goss --version 2>/dev/null | grep -q '#{goss_version}'"
  end
else
  unsupported_platform! node[:platform]
end
