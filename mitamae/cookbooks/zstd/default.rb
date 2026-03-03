if node[:platform] == 'darwin'
  package 'zstd'
elsif node[:platform] == 'ubuntu' || node[:platform] == 'debian'
  package 'zstd' do
    user 'root'
  end
end
