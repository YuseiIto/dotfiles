if node[:platform] == 'darwin'
  package 'fastfetch'
elsif %w[ubuntu debian].include?(node[:platform])
  fastfetch_version = '2.63.1'

  arch = case node[:os_arch]
         when 'x86_64' then 'amd64'
         when 'arm64' then 'aarch64'
         end

  archive_url = "https://github.com/fastfetch-cli/fastfetch/releases/download/#{fastfetch_version}/fastfetch-linux-#{arch}.deb"

  execute 'Install fastfetch' do
    user 'root'
    command <<~EOC
      curl -fsSL -o /tmp/fastfetch.deb #{archive_url}
      apt-get install -y /tmp/fastfetch.deb
      rm /tmp/fastfetch.deb
    EOC
    not_if "fastfetch --version 2>/dev/null | grep -q '#{fastfetch_version}'"
  end
end
