# Install avrdude - AVR microcontroller programmer
if %w[ubuntu debian].include?(node[:platform])
  package 'avrdude' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'avrdude'
end
