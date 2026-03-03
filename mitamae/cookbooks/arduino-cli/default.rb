if node[:platform] == "darwin"
  package "arduino-cli"
elsif node[:platform] == "ubuntu" || node[:platform] == "debian"
  execute "Install arduino-cli via official installer" do
    command "curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/usr/local/bin sh"
    user "root"
    not_if "command -v arduino-cli"
  end
end
