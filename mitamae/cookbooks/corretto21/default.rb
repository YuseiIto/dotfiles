if node[:platform] == 'darwin'
  brew_cask 'corretto@21'
elsif %w[ubuntu debian].include?(node[:platform])
  execute 'add corretto apt repository' do
    command <<~EOC
      curl -fsSL https://apt.corretto.aws/corretto.key | gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" | tee /etc/apt/sources.list.d/corretto.list
      apt-get update
    EOC
    user 'root'
    not_if 'test -f /etc/apt/sources.list.d/corretto.list'
  end

  package 'java-21-amazon-corretto-jdk' do
    user 'root'
  end
end
