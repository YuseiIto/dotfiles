if node[:platform] == 'darwin'
  brew_cask 'docker'
elsif %w[ubuntu debian].include?(node[:platform])
  # Docker's repository is keyed by distro codename (e.g. noble/bookworm).
  codename = '$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")'

  apt_repository 'docker' do
    key_url "https://download.docker.com/linux/#{node[:platform]}/gpg"
    repo "https://download.docker.com/linux/#{node[:platform]} #{codename} stable"
  end

  # Install Docker Engine and plugins. docker-ce-rootless-extras ships the
  # dockerd-rootless.sh launcher used to run the daemon without root.
  %w[
    docker-ce
    docker-ce-cli
    containerd.io
    docker-buildx-plugin
    docker-compose-plugin
    docker-ce-rootless-extras
  ].each do |pkg|
    package pkg do
      user 'root'
    end
  end

  # Prerequisites for rootless Docker: user-namespace mapping (uidmap),
  # a rootless overlay backend (fuse-overlayfs) and userspace networking
  # (slirp4netns). dbus-user-session lets the per-user session start cleanly.
  %w[uidmap dbus-user-session fuse-overlayfs slirp4netns].each do |pkg|
    package pkg do
      user 'root'
    end
  end
else
  unsupported_platform! node[:platform]
end
