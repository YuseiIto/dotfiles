# Install avrdude - AVR microcontroller programmer
if ['ubuntu', 'debian'].include?(node[:platform])
  package 'avrdude' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'avrdude'
end
