if node[:platform] == 'darwin'
  execute 'install cncjs via homebrew cask' do
    command 'brew install --cask cncjs'
    not_if 'brew list --cask cncjs'
  end
elsif node[:platform] == 'debian' || node[:platform] == 'ubuntu'
  include_recipe '../../cookbooks/nodenv'

  execute 'Install cncjs via npm' do
    command 'npm install -g cncjs'
    not_if 'command -v cncjs'
  end
end
