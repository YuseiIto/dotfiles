if node[:platform] == 'darwin'
  package 'typescript-language-server'
elsif %w[ubuntu debian].include?(node[:platform])
  npm_global_package 'typescript', bin_name: 'tsc'
  npm_global_package 'typescript-language-server'
end
