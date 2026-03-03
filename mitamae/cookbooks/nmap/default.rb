# Install nmap - network discovery and security auditing tool
if node[:platform] == 'ubuntu' || node[:platform] == 'debian'
  package 'nmap' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'nmap'
end
