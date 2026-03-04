if node[:platform] == 'darwin'
  package 'typescript-language-server'
elsif %w[ubuntu debian].include?(node[:platform])
  npm_global_package 'typescript' do
    bin_name 'tsc'
  end
  npm_global_package 'typescript-language-server'
end
