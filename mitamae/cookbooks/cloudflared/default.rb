if node[:platform] == "ubuntu" || node[:platform] == "debian"
  "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${node[:os_arch]}.deb"
else
  # macOS, Arch Linux
  package "cloudflared"
end
