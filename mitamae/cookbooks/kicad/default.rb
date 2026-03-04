if node[:platform] == 'darwin'
  brew_cask 'kicad'
elsif %w[ubuntu debian].include?(node[:platform])
  package 'kicad' do
    user 'root'
  end
end
