if ['ubuntu', 'debian'].include?(node[:platform])
  package 'default-mysql-client' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'mysql-client'
end
