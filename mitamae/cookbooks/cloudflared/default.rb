if %w[ubuntu debian].include?(node[:platform])

  arch = case node[:os_arch]
         when 'x86_64' then 'amd64'
         when 'arm64' then 'arm64'
         end

  archive_url = "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-#{arch}.deb"

  execute 'Install cloudflared' do
    user 'root'
    command <<~EOC
      curl -L -o /tmp/cloudflared.deb #{archive_url}
      apt-get install -y /tmp/cloudflared.deb
      rm /tmp/cloudflared.deb
    EOC
    not_if 'command -v cloudflared'
  end
else
  # macOS, Arch Linux
  package 'cloudflared'
end
