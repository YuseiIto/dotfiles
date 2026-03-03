# Install CMake - cross-platform build system
if %w[ubuntu debian].include?(node[:platform])
  package 'cmake' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'cmake'
end
