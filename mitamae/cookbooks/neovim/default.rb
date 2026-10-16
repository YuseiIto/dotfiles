# renovate: datasource=github-releases depName=neovim/neovim extractVersion=^v(?<version>.+)$
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
  # renovate: datasource=github-release-attachments depName=neovim/neovim
  nvim_arm64_sha256 = 'v0.11.6@8ddc0c101846145e830b17bbca50782ca9307eee4fab539d9e2ddaf8793c06f1'
  # renovate: datasource=github-release-attachments depName=neovim/neovim
  nvim_x86_64_sha256 = 'v0.11.6@2fc90b962327f73a78afbfb8203fd19db8db9cdf4ee5e2bef84704339add89cc'
  nvim_sha256 = (node[:os_arch] == 'arm64' ? nvim_arm64_sha256 : nvim_x86_64_sha256).split('@', 2).last
  nvim_archive = "#{nvim_release}.tar.gz"
  url = "https://github.com/neovim/neovim/releases/download/v#{nvim_version}/#{nvim_archive}"

  execute 'Install neovim binary' do
    command <<~EOC
      set -eu
      work_dir="$(mktemp -d)"
      trap 'rm -rf "$work_dir"' EXIT
      curl -fsSL -o "$work_dir/#{nvim_archive}" #{url}
      echo "#{nvim_sha256}  $work_dir/#{nvim_archive}" | sha256sum -c -
      tar -C /opt -xzf "$work_dir/#{nvim_archive}"
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
