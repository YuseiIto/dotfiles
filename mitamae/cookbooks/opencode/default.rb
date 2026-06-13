if node[:platform] == 'darwin'
  package 'opencode'
elsif %w[ubuntu debian].include?(node[:platform])
  npm_global_package 'opencode-ai' do
    bin_name 'opencode'
  end
else
  unsupported_platform! node[:platform]
end
