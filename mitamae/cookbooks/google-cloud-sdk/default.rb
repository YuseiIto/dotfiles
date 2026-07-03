if node[:platform] == 'darwin'
  brew_cask 'google-cloud-sdk'
elsif %w[ubuntu debian].include?(node[:platform])
  # Official installation guide: https://cloud.google.com/sdk/docs/install-sdk#debian_and_ubuntu
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
