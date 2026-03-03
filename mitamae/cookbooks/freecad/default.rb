if node[:platform] == 'darwin'
  execute 'install freecad via homebrew cask' do
    command 'brew install --cask freecad'
    not_if 'brew list --cask freecad'
  end
elsif %w[ubuntu debian].include?(node[:platform])
  package 'freecad' do
    user 'root'
  end
end
