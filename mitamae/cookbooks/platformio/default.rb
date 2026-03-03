if node[:platform] == "darwin"
  package "platformio"
elsif node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "python3" do
    user "root"
  end

  package "python3-venv" do
    user "root"
  end

  execute "Install PlatformIO via official installer" do
    command <<~EOC
      curl -fsSL -o /tmp/get-platformio.py https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py
      python3 /tmp/get-platformio.py
      rm -f /tmp/get-platformio.py
    EOC
    not_if "command -v pio || test -f ~/.platformio/penv/bin/pio"
  end
end
