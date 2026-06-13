unsupported_platform! node[:platform] unless %w[ubuntu debian].include?(node[:platform])

# Requires gum for interactive disk selection
include_recipe '../gum'

# Required tools for the installer
%w[parted dosfstools rsync fdisk].each do |pkg|
  package pkg do
    user 'root'
  end
end

# Place the installer script. mitamae's file resources don't honour `user`
# for the privileged temp-file staging, so install it via a root `execute`
# (mirroring how docker/Dockerfile.pine installs entrypoint.sh).
installer_script = File.join(File.dirname(__FILE__), 'files', 'yuseiito-dev-install.sh')

execute 'Install yuseiito-dev-install' do
  command "install -m 0755 #{installer_script} /usr/local/bin/yuseiito-dev-install"
  user 'root'
  not_if "cmp -s #{installer_script} /usr/local/bin/yuseiito-dev-install"
end
