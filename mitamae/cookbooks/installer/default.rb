return unless %w[ubuntu debian].include?(node[:platform])

# Requires gum for interactive disk selection
include_recipe '../gum'

# Required tools for the installer
%w[parted dosfstools rsync fdisk].each do |pkg|
  package pkg
end

# Place the installer script
remote_file '/usr/local/bin/yuseiito-dev-install' do
  source 'files/yuseiito-dev-install.sh'
  mode '0755'
  owner 'root'
  group 'root'
end
