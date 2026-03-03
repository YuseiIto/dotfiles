if node[:platform] == 'darwin'
  package 'uv'
elsif ['ubuntu', 'debian'].include?(node[:platform])
  execute 'Install uv' do
    command 'curl -LsSf https://astral.sh/uv/install.sh | sh'
    not_if 'command -v uv'
  end
end
