# Install direnv - directory-level environment variable loader
if %w[ubuntu debian].include?(node[:platform])
  package 'direnv' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'direnv'
end
