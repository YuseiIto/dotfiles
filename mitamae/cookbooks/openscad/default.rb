if node[:platform] == 'darwin'
  execute 'install openscad via homebrew cask' do
    command 'brew install --cask openscad'
    not_if 'brew list --cask openscad'
  end
elsif node[:platform] == 'ubuntu' || node[:platform] == 'debian'
  package 'openscad' do
    user 'root'
  end
end
