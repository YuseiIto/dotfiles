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
      curl -fsSLO #{url}
      tar -C /opt -xzf #{nvim_archive}
      rm #{nvim_archive}
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
  MItamae.logger.error "unsupported platform #{node[:platform]}: #{__FILE__}:#{__LINE__}"
  exit 1
end

home = ENV['HOME']

dotconfig 'nvim'

# Roleで定義されたフラグを元に features.lua を生成
template "#{home}/.config/nvim/lua/features.lua" do
  source 'templates/features.lua.erb'
  variables(
    editor_features: node[:editor_features]
  )
end
