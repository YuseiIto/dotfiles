if node[:platform] == 'darwin'
  package 'lua-language-server'
elsif ['ubuntu', 'debian'].include?(node[:platform])
  lls_version = '3.13.5'

  arch = case node[:os_arch]
         when 'arm64' then 'linux-arm64'
         else 'linux-x64'
         end

  lls_archive = "lua-language-server-#{lls_version}-#{arch}.tar.gz"
  url = "https://github.com/LuaLS/lua-language-server/releases/download/#{lls_version}/#{lls_archive}"

  directory '/opt/lua-language-server' do
    user 'root'
  end

  execute 'Install lua-language-server' do
    command <<~EOC
      curl -fsSLO #{url}
      tar xzf #{lls_archive} -C /opt/lua-language-server
      rm -f #{lls_archive}
    EOC
    user 'root'
    not_if "/opt/lua-language-server/bin/lua-language-server --version 2>/dev/null | grep -q '#{lls_version}'"
  end

  link '/usr/local/bin/lua-language-server' do
    to '/opt/lua-language-server/bin/lua-language-server'
    user 'root'
    force true
  end
end
