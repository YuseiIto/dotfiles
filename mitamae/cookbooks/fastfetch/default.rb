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

  execute 'Install fastfetch' do
    user 'root'
    command <<~EOC
      set -eu
      work_dir="$(mktemp -d)"
      trap 'rm -rf "$work_dir"' EXIT
      curl -fsSL -o "$work_dir/fastfetch.deb" #{archive_url}
      apt-get install -y "$work_dir/fastfetch.deb"
    EOC
    not_if "fastfetch --version 2>/dev/null | grep -q '#{fastfetch_version}'"
  end
else
  unsupported_platform! node[:platform]
end
