if node[:platform] == 'darwin'
  brew_cask 'freecad'
elsif %w[ubuntu debian].include?(node[:platform])
  package 'freecad' do
    user 'root'
  end
end
