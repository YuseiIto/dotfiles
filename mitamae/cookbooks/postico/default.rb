if node[:platform] == 'darwin'
  execute 'install postico via homebrew cask' do
    command 'brew install --cask postico'
    not_if 'brew list --cask postico'
  end
end
