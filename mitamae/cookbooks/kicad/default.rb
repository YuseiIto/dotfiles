if node[:platform] == 'darwin'
  execute 'install kicad via homebrew cask' do
    command 'brew install --cask kicad'
    not_if 'brew list --cask kicad'
  end
elsif %w[ubuntu debian].include?(node[:platform])
  package 'kicad' do
    user 'root'
  end
end
