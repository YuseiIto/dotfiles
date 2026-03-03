if node[:platform] == 'darwin'
  execute 'install google-chrome via homebrew cask' do
    command 'brew install --cask google-chrome'
    not_if 'brew list --cask google-chrome'
  end
elsif node[:platform] == 'ubuntu' || node[:platform] == 'debian'
  execute 'Add Google Chrome APT repository' do
    command <<~EOC
      curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
      echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
      apt-get update
    EOC
    user 'root'
    not_if 'test -f /etc/apt/sources.list.d/google-chrome.list'
  end
  package 'google-chrome-stable' do
    user 'root'
  end
end
