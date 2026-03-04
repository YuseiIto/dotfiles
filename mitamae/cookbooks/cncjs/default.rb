if node[:platform] == 'darwin'
  execute 'install cncjs via homebrew cask' do
    command 'brew install --cask cncjs'
    not_if 'brew list --cask cncjs'
  end
elsif %w[debian ubuntu].include?(node[:platform])
  npm_global_package 'cncjs'
end
