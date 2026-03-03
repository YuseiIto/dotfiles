if node[:platform] == 'darwin'
  execute 'install arduino-ide via homebrew cask' do
    command 'brew install --cask arduino-ide'
    not_if 'brew list --cask arduino-ide'
  end
else
  # Fail if not supported platform
  raise "Unsupported platform: #{node[:platform]}"
end
