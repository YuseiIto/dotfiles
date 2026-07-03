if node[:platform] == 'darwin'
  package 'gh'
elsif %w[ubuntu debian].include?(node[:platform])
  apt_repository 'github-cli' do
    key_url 'https://cli.github.com/packages/githubcli-archive-keyring.gpg'
    repo 'https://cli.github.com/packages stable main'
  end

  package 'gh' do
    user 'root'
  end
else
  unsupported_platform! node[:platform]
end
