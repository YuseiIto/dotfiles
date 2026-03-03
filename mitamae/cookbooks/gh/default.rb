if node[:platform] == 'darwin'
  package 'gh'
elsif %w[ubuntu debian].include?(node[:platform])
  execute 'Add GitHub CLI apt repository' do
    command <<~EOC
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
      chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | tee /etc/apt/sources.list.d/github-cli.list
      apt-get update
    EOC
    user 'root'
    not_if 'test -f /etc/apt/sources.list.d/github-cli.list'
  end

  package 'gh' do
    user 'root'
  end
end
