nvim_version = '0.11.6'

case node[:platform]
when 'darwin'
  package 'neovim'
when 'ubuntu', 'debian'

  # Ensure curl is installed for downloading Neovim tarball
  package 'curl' do
    user 'root'
  end

  nvim_release = "nvim-linux-#{node[:os_arch]}"
  nvim_archive = "#{nvim_release}.tar.gz"
  url = "https://github.com/neovim/neovim/releases/download/v#{nvim_version}/#{nvim_archive}"

  execute 'Install neovim binary' do
    command <<~EOC
      curl -fsSL -o /tmp/#{nvim_archive} #{url}
      tar -C /opt -xzf /tmp/#{nvim_archive}
      rm /tmp/#{nvim_archive}
    EOC
    user 'root'
    not_if "/opt/#{nvim_release}/bin/nvim --version | grep -q 'NVIM v#{nvim_version}'" # Skip if the correct version is already installed
  end

  # Create a symlink to make nvim accessible for all users
  link '/usr/local/bin/nvim' do
    to "/opt/#{nvim_release}/bin/nvim"
    user 'root'
    force true
  end

when 'arch'
  package 'neovim' do
    user 'root'
  end
else
  unsupported_platform! node[:platform]
end

home = ENV['HOME']

# tree-sitter CLI is required for compiling parsers without prebuilt binaries
include_recipe '../../cookbooks/tree-sitter'

dotconfig 'nvim'

# Roleで定義されたフラグを元に features.lua を生成
template "#{home}/.config/nvim/lua/features.lua" do
  source 'templates/features.lua.erb'
  variables(
    editor_features: node[:editor_features]
  )
end

# Clean up packer.nvim artifacts left from the previous plugin manager
file "#{home}/.config/nvim/plugin/packer_compiled.lua" do
  action :delete
end

execute 'Remove packer.nvim install dir' do
  command "rm -rf #{home}/.local/share/nvim/site/pack/packer"
  only_if "test -d #{home}/.local/share/nvim/site/pack/packer"
end

execute 'Install neovim plugins via lazy.nvim' do
  command 'nvim --headless "+Lazy! sync" +qa'
  not_if "test -d #{home}/.local/share/nvim/lazy/onedark.nvim"
end
