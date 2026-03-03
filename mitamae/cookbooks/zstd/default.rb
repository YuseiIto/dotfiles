if node[:platform] == 'darwin'
  package 'zstd'
elsif ['ubuntu', 'debian'].include?(node[:platform])
  package 'zstd' do
    user 'root'
  end
end
