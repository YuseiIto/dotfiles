# Normalize architecture naming across all roles
node[:os_arch] = case node[:kernel][:machine]
                 when 'aarch64', 'arm64' then 'arm64'
                 else 'x86_64'
                 end

# Symlink dotfiles to the user's home directory
# Pass `cookbook_dir: __dir__` from the calling cookbook so the files/ path resolves correctly.
define :dotfile, source: nil, cookbook_dir: nil do
  source_file = params[:source] || params[:name]
  dir = params[:cookbook_dir]

  link File.join(ENV['HOME'], params[:name]) do
    to File.join(dir, 'files', source_file)
    force true
  end
end

# Symlink configuration files to the user's .config directory
# Source files are resolved from the repository root's .config/ directory.
define :dotconfig, source: nil do
  source_file = params[:source] || params[:name]
  config_dir = File.join(ENV['HOME'], '.config')

  # Ensure .config directory exists
  directory config_dir

  link File.join(config_dir, params[:name]) do
    to File.expand_path("../../.config/#{source_file}", File.dirname(__FILE__))
    force true
  end
end

# Install a Python tool via uv
define :uv_tool_package, bin_name: nil do
  include_recipe File.expand_path('../cookbooks/uv', File.dirname(__FILE__))

  pkg_name = params[:name]
  cmd_name = params[:bin_name] || pkg_name

  execute "uv tool install #{pkg_name}" do
    not_if "command -v #{cmd_name} >/dev/null 2>&1"
  end
end

# Install a Rust binary via cargo
define :cargo_package, bin_name: nil do
  include_recipe File.expand_path('../cookbooks/rust', File.dirname(__FILE__))

  pkg_name = params[:name]
  cmd_name = params[:bin_name] || pkg_name
  home = ENV['HOME']

  execute "cargo install #{pkg_name}" do
    command "bash -c 'source #{home}/.cargo/env && cargo install #{pkg_name}'"
    not_if "test -f #{home}/.cargo/bin/#{cmd_name}"
  end
end

# Install a macOS application via Homebrew Cask
define :brew_cask do
  cask_name = params[:name]
  execute "install #{cask_name} via homebrew cask" do
    command "brew install --cask #{cask_name}"
    not_if "brew list --cask #{cask_name} >/dev/null 2>&1"
  end
end

# Install a Node.js package globally via npm
define :npm_global_package, version: nil, bin_name: nil do
  include_recipe File.expand_path('../cookbooks/nodenv', File.dirname(__FILE__))

  pkg_name = params[:name]
  version_suffix = params[:version] ? "@#{params[:version]}" : ''

  # Package name and binary name may differ (e.g., opencode-ai -> opencode)
  cmd_name = params[:bin_name] || pkg_name

  execute "npm install -g #{pkg_name}#{version_suffix}" do
    not_if "command -v #{cmd_name} >/dev/null 2>&1"
    notifies :run, "execute[nodenv rehash for #{pkg_name}]"
  end

  # Rehash nodenv shims after installing a new global package (`notifies`)
  execute "nodenv rehash for #{pkg_name}" do
    command "rm -f #{ENV['HOME']}/.nodenv/shims/.nodenv-shim && nodenv rehash"
    action :nothing
  end
end

# Install a system package with platform-specific name overrides
# Automatically handles debian/ubuntu vs darwin platform differences.
# Supports packages with the same name across platforms (e.g., ffmpeg)
# or different names (e.g., sqlite3 on debian, sqlite on darwin).
define :cross_platform_package, darwin_name: nil, debian_name: nil do
  pkg = params[:name]
  if %w[ubuntu debian].include?(node[:platform])
    package(params[:debian_name] || pkg) { user 'root' }
  elsif node[:platform] == 'darwin'
    package(params[:darwin_name] || pkg)
  end
end
