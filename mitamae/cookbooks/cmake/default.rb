# Install CMake - cross-platform build system
if ['ubuntu', 'debian'].include?(node[:platform])
  package 'cmake' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'cmake'
end
