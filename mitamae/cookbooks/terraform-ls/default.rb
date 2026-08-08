if node[:platform] == 'darwin'
  # homebrew-core carries terraform-ls (it is MPL-2.0, so the BUSL relicensing
  # that got terraform itself removed did not apply) and tracks it ahead of
  # hashicorp/tap, so prefer core over the vendor tap.
  package 'terraform-ls'
elsif %w[ubuntu debian].include?(node[:platform])
  # HashiCorp's repository is keyed by distro codename (e.g. noble/bookworm).
  codename = '$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")'

  apt_repository 'hashicorp' do
    key_url 'https://apt.releases.hashicorp.com/gpg'
    repo "https://apt.releases.hashicorp.com #{codename} main"
  end

  package 'terraform-ls' do
    user 'root'
  end
else
  unsupported_platform! node[:platform]
end
