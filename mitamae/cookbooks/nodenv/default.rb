global_nodejs_version = '24.14.0'

home = ENV['HOME']
nodenv_root = "#{home}/.nodenv"

# Ensure nodenv binary + shims are in PATH for subsequent recipes in this run
[
  "#{nodenv_root}/shims",
  "#{nodenv_root}/bin"
].each do |dir|
  ENV['PATH'] = "#{dir}:#{ENV['PATH']}" unless ENV['PATH'].include?(dir)
end

if node[:platform] == 'darwin'
  package 'nodenv'
  package 'node-build'
elsif %w[ubuntu debian].include?(node[:platform])
  execute 'Install nodenv via git' do
    command "git clone https://github.com/nodenv/nodenv.git #{nodenv_root}"
    not_if "test -d #{nodenv_root}"
  end

  directory "#{nodenv_root}/plugins" do
    action :create
  end

  execute 'Install node-build plugin' do
    command "git clone https://github.com/nodenv/node-build.git #{nodenv_root}/plugins/node-build"
    not_if "test -d #{nodenv_root}/plugins/node-build"
  end
end

# Install and set the global Node version as two separate resources so a
# half-configured environment (version installed but global unset) is repaired
# on a subsequent run. Mirrors ruby/default.rb.
execute "Install Node #{global_nodejs_version} via nodenv" do
  command <<-EOS
    eval "$(nodenv init -)"
    nodenv install #{global_nodejs_version} -s
  EOS
  not_if "test -x #{nodenv_root}/versions/#{global_nodejs_version}/bin/node"
end

execute "Set nodenv global to #{global_nodejs_version}" do
  command <<-EOS
    eval "$(nodenv init -)"
    nodenv global #{global_nodejs_version}
  EOS
  not_if "test \"$(nodenv global)\" = '#{global_nodejs_version}'"
end
