unsupported_platform!(node[:platform]) unless node[:platform] == 'darwin'

brew_cask 'arduino-ide'
