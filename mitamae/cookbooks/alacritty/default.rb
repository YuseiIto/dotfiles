if node[:platform] == 'darwin'
  brew_cask 'alacritty'
elsif %w[ubuntu debian].include?(node[:platform])
  package 'snapd' do
    user 'root'
  end

  execute 'Install Alacritty via snap' do
    command 'snap install alacritty --classic'
    user 'root'
    not_if 'snap list | grep -q alacritty'
  end
end

dotconfig 'alacritty'
