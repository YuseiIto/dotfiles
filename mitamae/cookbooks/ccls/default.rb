# Install ccls - C/C++/ObjC language server
if ['ubuntu', 'debian'].include?(node[:platform])
  package 'ccls' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'ccls'
end
