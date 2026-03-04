if node[:platform] == 'darwin'
  brew_cask 'cncjs'
elsif %w[debian ubuntu].include?(node[:platform])
  npm_global_package 'cncjs'
end
