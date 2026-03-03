if %w[ubuntu debian].include?(node[:platform])
  package 'build-essential' do
    user 'root'
  end
end
