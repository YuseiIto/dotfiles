if node[:platform] == 'darwin'
  package 'llvm'
elsif %w[ubuntu debian].include?(node[:platform])
  package 'clangd' do
    user 'root'
  end
end
