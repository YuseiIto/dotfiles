if node[:platform] == 'darwin'
  package 'python-lsp-server'
elsif %w[ubuntu debian].include?(node[:platform])
  # Use uv to install if possible, otherwise pip
  include_recipe '../uv'
  execute 'Install python-lsp-server via uv' do
    command 'uv tool install python-lsp-server'
    not_if 'command -v pylsp'
  end
end
