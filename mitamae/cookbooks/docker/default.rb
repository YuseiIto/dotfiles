if node[:platform] == 'darwin'
  brew_cask 'docker'
elsif %w[ubuntu debian].include?(node[:platform])
  # Prerequisites
  package 'ca-certificates' do
    user 'root'
  end

  package 'curl' do
    user 'root'
  end

  # Add Docker's official GPG key
  execute 'add docker gpg key' do
    command <<~EOC
      install -m 0755 -d /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/#{node[:platform]}/gpg -o /etc/apt/keyrings/docker.asc
      chmod a+r /etc/apt/keyrings/docker.asc
    EOC
    user 'root'
    not_if 'test -f /etc/apt/keyrings/docker.asc'
  end

  # Add Docker apt repository
  execute 'add docker apt repository' do
    command <<~EOC
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/#{node[:platform]} $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
      apt-get update -qq
    EOC
    user 'root'
    not_if 'test -f /etc/apt/sources.list.d/docker.list'
  end

  # Install Docker Engine and plugins
  %w[docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin].each do |pkg|
    package pkg do
      user 'root'
    end
  end
end
