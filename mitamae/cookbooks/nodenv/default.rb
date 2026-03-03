if node[:platform] == "darwin"
  package "nodenv"
elsif node[:platform] == "ubuntu" || node[:platform] == "debian"
  home = ENV["HOME"]
  nodenv_root = "#{home}/.nodenv"

  execute "Install nodenv via git" do
    command "git clone https://github.com/nodenv/nodenv.git #{nodenv_root}"
    not_if "test -d #{nodenv_root}"
  end

  execute "Compile nodenv dynamic bash extension" do
    include_recipe "../../cookbooks/build-essential"
    command "cd #{nodenv_root} && src/configure && make -C src"
    not_if "test -f #{nodenv_root}/src/realpath.dynlib"
  end

  directory "#{nodenv_root}/plugins" do
    action :create
  end

  execute "Install node-build plugin" do
    command "git clone https://github.com/nodenv/node-build.git #{nodenv_root}/plugins/node-build"
    not_if "test -d #{nodenv_root}/plugins/node-build"
  end
end
