if node[:platform] == 'darwin'
  execute 'install openscad via homebrew cask' do
    command 'brew install --cask openscad'
    not_if 'brew list --cask openscad'
  end
elsif ['ubuntu', 'debian'].include?(node[:platform])
  package 'openscad' do
    user 'root'
  end
end
