if node[:platform] == 'darwin'
  brew_cask 'corretto@21'
elsif %w[ubuntu debian].include?(node[:platform])
  apt_repository 'corretto' do
    key_url 'https://apt.corretto.aws/corretto.key'
    repo 'https://apt.corretto.aws stable main'
  end

  package 'java-21-amazon-corretto-jdk' do
    user 'root'
  end
else
  unsupported_platform! node[:platform]
end
