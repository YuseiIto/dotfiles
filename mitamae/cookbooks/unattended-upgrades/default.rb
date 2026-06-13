if %w[ubuntu debian].include?(node[:platform])
  package 'unattended-upgrades' do
    user 'root'
  end

  # Enable periodic apt update and unattended upgrade runs.
  template '/etc/apt/apt.conf.d/20auto-upgrades' do
    source 'templates/20auto-upgrades.erb'
    user 'root'
  end

  # Apply security-origin updates only; never reboot automatically.
  template '/etc/apt/apt.conf.d/50unattended-upgrades' do
    source 'templates/50unattended-upgrades.erb'
    user 'root'
  end
end
