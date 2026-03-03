if node[:platform] == 'darwin'
  execute 'install firefox via homebrew cask' do
    command 'brew install --cask firefox'
    not_if 'brew list --cask firefox'
  end
elsif ['ubuntu', 'debian'].include?(node[:platform])
  execute 'Add Mozilla APT repository' do
    command <<~EOC
      install -d -m 0755 /etc/apt/keyrings
      curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg -o /etc/apt/keyrings/packages.mozilla.org.asc
      echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" > /etc/apt/sources.list.d/mozilla.list
      apt-get update
    EOC
    user 'root'
    not_if 'test -f /etc/apt/sources.list.d/mozilla.list'
  end
  package 'firefox' do
    user 'root'
  end
end
