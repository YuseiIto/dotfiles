if node[:platform] == 'darwin'
  package 'hashicorp/tap/terraform'
elsif %w[ubuntu debian].include?(node[:platform])
  # HashiCorp's repository is keyed by distro codename (e.g. noble/bookworm).
  codename = '$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")'

  apt_repository 'hashicorp' do
    key_url 'https://apt.releases.hashicorp.com/gpg'
    repo "https://apt.releases.hashicorp.com #{codename} main"
  end

  package 'terraform' do
    user 'root'
  end
else
  unsupported_platform! node[:platform]
end
