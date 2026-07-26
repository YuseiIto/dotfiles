if node[:platform] == 'darwin'
  package 'opentofu'
elsif %w[ubuntu debian].include?(node[:platform])
  # Unlike HashiCorp's repository, OpenTofu's is served from packagecloud under a
  # single distro-agnostic `any` suite, so there is no codename to interpolate.
  # It also needs two keys: the release key that signs the packages and the
  # packagecloud key that signs the repository metadata.
  # Ref: https://opentofu.org/docs/intro/install/deb/
  apt_repository 'opentofu' do
    key_url %w[
      https://get.opentofu.org/opentofu.gpg
      https://packages.opentofu.org/opentofu/tofu/gpgkey
    ]
    repo 'https://packages.opentofu.org/opentofu/tofu/any/ any main'
  end

  package 'tofu' do
    user 'root'
  end
else
  unsupported_platform! node[:platform]
end
