if node[:platform] == 'darwin'
  package 'uv'
elsif %w[ubuntu debian].include?(node[:platform])
  execute 'Install uv' do
    command 'curl -LsSf https://astral.sh/uv/install.sh | sh'
    not_if 'command -v uv'
  end
end

# Ensure ~/.local/bin is in PATH for subsequent recipes in this mitamae run
uv_bin_dir = "#{ENV['HOME']}/.local/bin"
ENV['PATH'] = "#{uv_bin_dir}:#{ENV['PATH']}" unless ENV['PATH'].include?(uv_bin_dir)
