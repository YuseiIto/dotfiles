if node[:platform] == 'darwin'
  package 'fastfetch'
elsif %w[ubuntu debian].include?(node[:platform])
  # renovate: datasource=github-releases depName=fastfetch-cli/fastfetch
  fastfetch_version = '2.63.1'

  arch = case node[:os_arch]
         when 'x86_64' then 'amd64'
         when 'arm64' then 'aarch64'
         end

  archive_url = "https://github.com/fastfetch-cli/fastfetch/releases/download/#{fastfetch_version}/fastfetch-linux-#{arch}.deb"
  # renovate: datasource=github-release-attachments depName=fastfetch-cli/fastfetch
  fastfetch_arm64_sha256 = '2.63.1@9e6f22ac5585383d724fdc4a330e12b3e117152705c26891752234c074c46ed5'
  # renovate: datasource=github-release-attachments depName=fastfetch-cli/fastfetch
  fastfetch_x86_64_sha256 = '2.63.1@d0239b79c2082f30c0d519ec9af8e80f965b3cb873f4abd99ac4d8db1c48adf3'
  fastfetch_sha256 = ReleasePin.sha256(node[:os_arch] == 'arm64' ? fastfetch_arm64_sha256 : fastfetch_x86_64_sha256,
                                       "fastfetch #{node[:os_arch]}")

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
