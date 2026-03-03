# Install avrdude - AVR microcontroller programmer
if node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "avrdude" do
    user "root"
  end
elsif node[:platform] == "darwin"
  package "avrdude"
end
