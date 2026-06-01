global_ruby_version = '4.0.5'

home = ENV['HOME']
rbenv_root = "#{home}/.rbenv"

# Ensure rbenv binary + shims are in PATH for subsequent recipes in this mitamae run
[
  "#{rbenv_root}/shims",
  "#{rbenv_root}/bin"
].each do |dir|
  ENV['PATH'] = "#{dir}:#{ENV['PATH']}" unless ENV['PATH'].include?(dir)
end

cross_platform_package 'rbenv'
cross_platform_package 'ruby-build'

# Overlay ruby-build as an rbenv plugin so we get upstream-fresh Ruby definitions.
# rbenv prefers the plugin over the system-installed ruby-build, so the latest
# Ruby releases are available even when the distro package lags.
if %w[ubuntu debian].include?(node[:platform])
  directory "#{rbenv_root}/plugins" do
    action :create
  end

  execute 'Install ruby-build rbenv plugin' do
    command "git clone https://github.com/rbenv/ruby-build.git #{rbenv_root}/plugins/ruby-build"
    not_if "test -d #{rbenv_root}/plugins/ruby-build"
  end
end

execute "Install Ruby #{global_ruby_version} via rbenv" do
  command "rbenv install #{global_ruby_version} -s"
  not_if  "test -x #{rbenv_root}/versions/#{global_ruby_version}/bin/ruby"
end

execute "Set rbenv global to #{global_ruby_version}" do
  command "rbenv global #{global_ruby_version}"
  not_if  "test \"$(rbenv global)\" = '#{global_ruby_version}'"
end
