if node[:platform] == 'darwin'
  package 'opencode'
elsif %w[ubuntu debian].include?(node[:platform])
  npm_global_package 'opencode-ai', bin_name: 'opencode'
end
