# Install cloc - count lines of code
if ['ubuntu', 'debian'].include?(node[:platform])
  package 'cloc' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'cloc'
end
