global_nodejs_version = '24.14.0'

if node[:platform] == 'darwin'
  package 'nodenv'
elsif %w[ubuntu debian].include?(node[:platform])
  home = ENV['HOME']
  nodenv_root = "#{home}/.nodenv"

  # Ensure nodenv shims are in PATH for subsequent recipes in this mitamae run
  [
    "#{nodenv_root}/shims",
    "#{nodenv_root}/bin"
  ].each do |dir|
    ENV['PATH'] = "#{dir}:#{ENV['PATH']}" unless ENV['PATH'].include?(dir)
  end

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

  # Install and set global node version
  execute 'Install and set global node version' do
    command <<-EOS
      eval "$(nodenv init -)"
      nodenv install #{global_nodejs_version} -s
      nodenv global #{global_nodejs_version}
    EOS
    not_if "nodenv versions | grep -q '#{global_nodejs_version}'"
  end
end
