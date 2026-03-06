if node[:platform] == 'darwin'
  brew_cask 'processing'
elsif %w[debian ubuntu].include?(node[:platform])
  package 'snapd' do
    user 'root'
  end

  execute 'Install Processing via snap' do
    command 'snap install processing --classic'
    user 'root'
    not_if 'snap list | grep -q processing'
  end
end
