if %w[ubuntu debian].include?(node[:platform])
  # Ref: https://github.com/cloudflare/cloudflare-docs/blob/production/src/content/partials/cloudflare-one/tunnel/cloudflared-debian-install.mdx
  # The `any` suite is upstream's codename-independent channel, so this works
  # on both Ubuntu and Debian without substituting the release codename.
  apt_repository 'cloudflared' do
    key_url 'https://pkg.cloudflare.com/cloudflare-main.gpg'
    repo 'https://pkg.cloudflare.com/cloudflared any main'
  end

  package 'cloudflared' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'cloudflared'
else
  unsupported_platform! node[:platform]
end
