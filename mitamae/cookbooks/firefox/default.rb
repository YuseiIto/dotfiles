if node[:platform] == 'darwin'
  brew_cask 'firefox'
elsif %w[ubuntu debian].include?(node[:platform])
  apt_repository 'mozilla' do
    key_url 'https://packages.mozilla.org/apt/repo-signing-key.gpg'
    repo 'https://packages.mozilla.org/apt mozilla main'
  end

  package 'firefox' do
    user 'root'
  end
else
  unsupported_platform! node[:platform]
end
