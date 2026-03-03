# Install SQLite
if node[:platform] == 'ubuntu' || node[:platform] == 'debian'
  package 'sqlite3' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'sqlite'
end
