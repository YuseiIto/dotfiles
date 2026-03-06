raise "Unsupported platform: #{node[:platform]}" unless node[:platform] == 'darwin'

brew_cask 'arduino-ide'
