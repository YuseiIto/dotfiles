if %w[ubuntu debian].include?(node[:platform])
  package 'build-essential' do
    user 'root'
  end
else
  unsupported_platform! node[:platform]
end
