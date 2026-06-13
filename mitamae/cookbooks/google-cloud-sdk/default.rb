if node[:platform] == 'darwin'
  brew_cask 'google-cloud-sdk'
elsif %w[ubuntu debian].include?(node[:platform])
  # Official installation guide: https://cloud.google.com/sdk/docs/install-sdk#debian_and_ubuntu
  %w[apt-transport-https ca-certificates gnupg curl].each do |pkg|
    package pkg do
      user 'root'
    end
  end

  execute 'Add Google Cloud SDK APT repository' do
    command <<~EOC
      curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/google-cloud.gpg
      echo "deb [signed-by=/usr/share/keyrings/google-cloud.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list
      apt-get update
    EOC
    user 'root'
    not_if 'test -f /etc/apt/sources.list.d/google-cloud-sdk.list'
  end

  package 'google-cloud-cli' do
    user 'root'
  end
else
  unsupported_platform! node[:platform]
end
