# Install nmap - network discovery and security auditing tool
if %w[ubuntu debian].include?(node[:platform])
  package 'nmap' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'nmap'
end
