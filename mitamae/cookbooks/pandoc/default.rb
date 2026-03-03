# Install pandoc - universal document converter
if %w[ubuntu debian].include?(node[:platform])
  package 'pandoc' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'pandoc'
end
