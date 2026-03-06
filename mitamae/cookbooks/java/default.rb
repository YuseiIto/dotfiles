if node[:platform] == 'darwin'
  package 'temurin'
elsif %w[ubuntu debian].include?(node[:platform])
  package 'default-jdk' do
    user 'root'
  end
end
