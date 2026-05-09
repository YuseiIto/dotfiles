tree_sitter_version = '0.25.10'

case node[:platform]
when 'darwin'
  package 'tree-sitter-cli'
when 'ubuntu', 'debian'
  package 'curl' do
    user 'root'
  end

  arch = node[:os_arch] == 'arm64' ? 'arm64' : 'x64'
  archive = "tree-sitter-linux-#{arch}.gz"
  binary = '/usr/local/bin/tree-sitter'

  execute "Install tree-sitter CLI #{tree_sitter_version}" do
    command <<~EOC
      curl -fsSL -o /tmp/#{archive} https://github.com/tree-sitter/tree-sitter/releases/download/v#{tree_sitter_version}/#{archive}
      gunzip -f /tmp/#{archive}
      install -m 0755 /tmp/tree-sitter-linux-#{arch} #{binary}
      rm -f /tmp/tree-sitter-linux-#{arch}.gz /tmp/tree-sitter-linux-#{arch}
    EOC
    user 'root'
    not_if "test -x #{binary} && #{binary} --version | grep -q '#{tree_sitter_version}'"
  end
else
  Mitamae.logger.error "unsupported platform #{node[:platform]}: #{__FILE__}:#{__LINE__}"
  exit 1
end
