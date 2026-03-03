if %w[ubuntu debian].include?(node[:platform])
  package 'openocd' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'open-ocd'
end
