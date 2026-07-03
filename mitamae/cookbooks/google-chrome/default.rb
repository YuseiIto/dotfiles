if node[:platform] == 'darwin'
  brew_cask 'google-chrome'
elsif %w[ubuntu debian].include?(node[:platform])
  apt_repository 'google-chrome' do
    key_url 'https://dl.google.com/linux/linux_signing_key.pub'
    repo 'https://dl.google.com/linux/chrome/deb/ stable main'
  end

  package 'google-chrome-stable' do
    user 'root'
  end
else
  unsupported_platform! node[:platform]
end
