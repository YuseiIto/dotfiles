if node[:platform] == 'darwin'
  execute 'install processing via homebrew cask' do
    command 'brew install --cask processing'
    not_if 'brew list --cask processing'
  end
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
