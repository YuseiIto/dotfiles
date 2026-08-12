if node[:platform] == 'darwin'
  # NOTE: Do not use the pre-rename cask name google-cloud-sdk: brew still
  # accepts it, but reports gcloud-cli, which breaks the audit's name matching.
  brew_cask 'gcloud-cli'
elsif %w[ubuntu debian].include?(node[:platform])
  # Official installation guide: https://cloud.google.com/sdk/docs/install-sdk#debian_and_ubuntu
  # NOTE: The resource name is kept as google-cloud-sdk because it determines
  # the keyring/.list filenames already present on provisioned hosts; renaming
  # it would leave stale duplicates behind.
  apt_repository 'google-cloud-sdk' do
    key_url 'https://packages.cloud.google.com/apt/doc/apt-key.gpg'
    repo 'https://packages.cloud.google.com/apt cloud-sdk main'
  end

  package 'google-cloud-cli' do
    user 'root'
  end
else
  unsupported_platform! node[:platform]
end
