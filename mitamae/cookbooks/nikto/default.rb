# Install nikto - web server vulnerability scanner
if %w[ubuntu debian].include?(node[:platform])
  package 'nikto' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'nikto'
end
