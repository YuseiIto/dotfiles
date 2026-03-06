if node[:platform] == 'darwin'
  package 'gum'
elsif %w[ubuntu debian].include?(node[:platform])
  execute 'Add Charm.sh apt repository' do
    command <<~EOC
      mkdir -p /etc/apt/keyrings
       curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --batch --yes --dearmor -o /etc/apt/keyrings/charm.gpg
      echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | tee /etc/apt/sources.list.d/charm.list
      apt-get update
    EOC
    user 'root'
    not_if 'test -f /etc/apt/sources.list.d/charm.list'
  end

  package 'gum'
end
