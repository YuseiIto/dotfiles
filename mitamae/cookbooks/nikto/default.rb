# Install nikto - web server vulnerability scanner
if node[:platform] == 'ubuntu' || node[:platform] == 'debian'
  package 'nikto' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'nikto'
end
