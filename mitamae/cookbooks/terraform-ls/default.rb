if node[:platform] == 'darwin'
  package 'hashicorp/tap/terraform-ls'
elsif %w[ubuntu debian].include?(node[:platform])
  # Official way for debian/ubuntu
  execute 'Add HashiCorp GPG key' do
    command 'wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg'
    user 'root'
    not_if 'test -f /usr/share/keyrings/hashicorp-archive-keyring.gpg'
  end

  execute 'Add HashiCorp repo' do
    keyring_path = '/usr/share/keyrings/hashicorp-archive-keyring.gpg'
    repo_url = 'https://apt.releases.hashicorp.com'
    command "echo \"deb [signed-by=#{keyring_path}] #{repo_url} $(lsb_release -cs) main\" | tee /etc/apt/sources.list.d/hashicorp.list"
    user 'root'
    not_if 'test -f /etc/apt/sources.list.d/hashicorp.list'
  end
  execute 'apt-get update' do
    user 'root'
  end
  package 'terraform-ls' do
    user 'root'
  end
end
