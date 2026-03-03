if node[:platform] == 'darwin'
  execute 'install alacritty via homebrew cask' do
    command 'brew install --cask alacritty'
    not_if 'brew list --cask alacritty'
  end
elsif ['ubuntu', 'debian'].include?(node[:platform])
  package 'snapd' do
    user 'root'
  end

  execute 'Install Alacritty via snap' do
    command 'snap install alacritty --classic'
    user 'root'
    not_if 'snap list | grep -q alacritty'
  end
end
