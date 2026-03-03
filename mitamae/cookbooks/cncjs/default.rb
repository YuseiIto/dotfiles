if node[:platform] == 'darwin'
  execute 'install cncjs via homebrew cask' do
    command 'brew install --cask cncjs'
    not_if 'brew list --cask cncjs'
  end
elsif ['debian', 'ubuntu'].include?(node[:platform])
  include_recipe '../../cookbooks/nodenv'

  execute 'Install cncjs via npm' do
    command 'npm install -g cncjs'
    not_if 'command -v cncjs'
  end
end
