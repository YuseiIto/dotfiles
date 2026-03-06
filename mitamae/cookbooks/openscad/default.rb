if node[:platform] == 'darwin'
  brew_cask 'openscad'
elsif %w[ubuntu debian].include?(node[:platform])
  package 'openscad' do
    user 'root'
  end
end
