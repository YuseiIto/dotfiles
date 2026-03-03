# Install aria2 - lightweight multi-protocol download utility
if %w[ubuntu debian].include?(node[:platform])
  package 'aria2' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'aria2'
end
