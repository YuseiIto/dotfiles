if node[:platform] == 'darwin'
  package 'lua-language-server'
elsif %w[ubuntu debian].include?(node[:platform])
  # renovate: datasource=github-releases depName=LuaLS/lua-language-server
  lls_version = '3.13.5'

  arch = case node[:os_arch]
         when 'arm64' then 'linux-arm64'
         else 'linux-x64'
         end

  lls_archive = "lua-language-server-#{lls_version}-#{arch}.tar.gz"
  lls_sha256 = ReleasePin.for_arch(
    node[:os_arch], 'lua-language-server',
    # renovate: datasource=github-release-attachments depName=LuaLS/lua-language-server
    arm64: '3.13.5@ae3a05a1c6746e3ce9f29a9abd4e10b8a450c72ece53612343f4ac5fd11c6046',
    # renovate: datasource=github-release-attachments depName=LuaLS/lua-language-server
    x86_64: '3.13.5@5d4316291b8c79b145002318fbb7cc294a327c314e2711e590609b178478eb59'
  )
  url = "https://github.com/LuaLS/lua-language-server/releases/download/#{lls_version}/#{lls_archive}"

  directory '/opt/lua-language-server' do
    user 'root'
  end

  execute 'Install lua-language-server' do
    command <<~EOC
      set -eu
      work_dir="$(mktemp -d)"
      trap 'rm -rf "$work_dir"' EXIT
      curl -fsSL -o "$work_dir/#{lls_archive}" #{url}
      echo "#{lls_sha256}  $work_dir/#{lls_archive}" | sha256sum -c -
      tar xzf "$work_dir/#{lls_archive}" -C /opt/lua-language-server
    EOC
    user 'root'
    not_if "/opt/lua-language-server/bin/lua-language-server --version 2>/dev/null | grep -q '#{lls_version}'"
  end

  link '/usr/local/bin/lua-language-server' do
    to '/opt/lua-language-server/bin/lua-language-server'
    user 'root'
    force true
  end
else
  unsupported_platform! node[:platform]
end
