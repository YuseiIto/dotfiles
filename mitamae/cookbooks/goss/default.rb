goss_version = '0.4.9'
goss_arch = node[:os_arch] == 'arm64' ? 'arm64' : 'amd64'

if node[:platform] == 'darwin'
  execute 'install goss' do
    command <<~EOC
      curl -fsSL "https://github.com/goss-org/goss/releases/download/v#{goss_version}/goss-darwin-#{goss_arch}" \
        -o /usr/local/bin/goss
      chmod +x /usr/local/bin/goss
    EOC
    not_if 'command -v goss'
  end
elsif %w[ubuntu debian].include?(node[:platform])
  execute 'install goss' do
    command <<~EOC
      curl -fsSL "https://github.com/goss-org/goss/releases/download/v#{goss_version}/goss-linux-#{goss_arch}" \
        -o /usr/local/bin/goss
      chmod +x /usr/local/bin/goss
    EOC
    user 'root'
    not_if 'command -v goss'
  end
end
