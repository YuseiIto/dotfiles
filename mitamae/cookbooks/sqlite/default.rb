# Install SQLite
if %w[ubuntu debian].include?(node[:platform])
  package 'sqlite3' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'sqlite'
end
