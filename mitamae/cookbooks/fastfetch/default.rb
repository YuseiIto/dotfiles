if node[:platform] == 'darwin'
  package 'fastfetch'
elsif %w[ubuntu debian].include?(node[:platform])
  # renovate: datasource=github-releases depName=fastfetch-cli/fastfetch
  fastfetch_version = '2.70.0'

  arch = case node[:os_arch]
         when 'x86_64' then 'amd64'
         when 'arm64' then 'aarch64'
         end

  archive_url = "https://github.com/fastfetch-cli/fastfetch/releases/download/#{fastfetch_version}/fastfetch-linux-#{arch}.deb"
  fastfetch_sha256 = ReleasePin.for_arch(
    node[:os_arch], 'fastfetch',
    # renovate: datasource=github-release-attachments depName=fastfetch-cli/fastfetch
    arm64: '2.70.0@25053651486d97b8731dd6bc59e725944e39adcdcd903741334c1c3282a7281d',
    # renovate: datasource=github-release-attachments depName=fastfetch-cli/fastfetch
    x86_64: '2.70.0@06e9a1be9a863dc815f8a31a6b1abec7b29967be30084ffcc29c1bca072d801b'
  )

  execute 'Install fastfetch' do
    user 'root'
    command <<~EOC
      set -eu
      work_dir="$(mktemp -d)"
      trap 'rm -rf "$work_dir"' EXIT
      curl -fsSL -o "$work_dir/fastfetch.deb" #{archive_url}
      echo "#{fastfetch_sha256}  $work_dir/fastfetch.deb" | sha256sum -c -
      apt-get install -y "$work_dir/fastfetch.deb"
    EOC
    not_if "fastfetch --version 2>/dev/null | grep -q '#{fastfetch_version}'"
  end
else
  unsupported_platform! node[:platform]
end
