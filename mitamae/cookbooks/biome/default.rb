if node[:platform] == 'darwin'
  package 'biome'
elsif %w[ubuntu debian].include?(node[:platform])
  npm_global_package '@biomejs/biome', bin_name: 'biome'
end
