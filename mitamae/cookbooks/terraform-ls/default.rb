if node[:platform] == 'darwin'
  package 'hashicorp/tap/terraform-ls'
elsif %w[ubuntu debian].include?(node[:platform])
  package 'gnupg' do
    user 'root'
  end
  package 'curl' do
    user 'root'
  end

  # Official way for debian/ubuntu
  execute 'Add HashiCorp GPG key' do
    command 'curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg'
    user 'root'
    not_if 'test -f /usr/share/keyrings/hashicorp-archive-keyring.gpg'
  end

  execute 'Add HashiCorp repo' do
    key = '/usr/share/keyrings/hashicorp-archive-keyring.gpg'
    url = 'https://apt.releases.hashicorp.com'
    codename = "$(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs)"
    sources_list = '/etc/apt/sources.list.d/hashicorp.list'
    command "echo \"deb [arch=$(dpkg --print-architecture) signed-by=#{key}] #{url} #{codename} main\" >> #{sources_list}"
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
