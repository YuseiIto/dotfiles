# Normalize architecture naming across all roles
node[:os_arch] = case node[:kernel][:machine]
                 when 'aarch64', 'arm64' then 'arm64'
                 when 'x86_64' then 'x86_64'
                 else raise "Unsupported architecture: #{node[:kernel][:machine]}"
                 end

# Abort the run when a cookbook is executed on a platform it does not support.
#
# Cookbooks are only ever included in roles whose platform they target, so
# reaching this means the role/platform combination is misconfigured. Failing
# loudly surfaces the mistake immediately instead of silently skipping the
# installation and leaving a half-provisioned host. Pass `node[:platform]` so
# the message names the offending platform.
define :unsupported_platform! do
  raise "Unsupported platform: #{params[:name]}"
end

# Symlink dotfiles to the user's home directory
# Pass `cookbook_dir: File.dirname(__FILE__)` from the calling cookbook so the files/ path resolves correctly.
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

# Configure a third-party APT repository on Debian/Ubuntu.
#
# Centralizes the "fetch signing key -> write sources.list -> apt-get update"
# boilerplate that every external-repo cookbook used to hand-roll, where the
# keyring location and arch pinning drifted arbitrarily. The signing key is
# normalized to binary with `gpg --dearmor` (which accepts both ASCII-armored
# and already-binary keys) and stored under /etc/apt/keyrings as `<name>.gpg`.
# Normalizing matters: apt's `signed-by` is extension-sensitive and rejects an
# armored key behind a `.gpg` name (NO_PUBKEY), so always dearmoring is what
# lets a single `.gpg` convention work for every upstream key. The source is
# scoped to that key via `signed-by` and pinned to the host architecture.
#
#   apt_repository 'docker' do
#     key_url "https://download.docker.com/linux/#{node[:platform]}/gpg"
#     repo    "https://download.docker.com/linux/#{node[:platform]} stable"
#   end
#
# `repo` is everything after the `[options]` block of the sources line, so it
# may embed shell (e.g. the distro codename via `$(. /etc/os-release; ...)`).
define :apt_repository, key_url: nil, repo: nil do
  name = params[:name]
  keyring = "/etc/apt/keyrings/#{name}.gpg"
  list = "/etc/apt/sources.list.d/#{name}.list"

  # The command below relies on curl (download), ca-certificates (TLS), and
  # gnupg (`gpg --dearmor`). Install them explicitly so the cookbook works on a
  # minimal base image instead of assuming these tools happen to be present.
  %w[ca-certificates curl gnupg].each do |pkg|
    package pkg do
      user 'root'
    end
  end

  execute "Add #{name} APT repository" do
    command <<~EOC
      install -d -m 0755 /etc/apt/keyrings
      curl -fsSL #{params[:key_url]} | gpg --dearmor --yes -o #{keyring}
      chmod a+r #{keyring}
      echo "deb [arch=$(dpkg --print-architecture) signed-by=#{keyring}] #{params[:repo]}" > #{list}
      apt-get update
    EOC
    user 'root'
    not_if "test -f #{list}"
  end
end

# Install a single executable from a GitHub release into /usr/local/bin.
#
# Collapses the "resolve arch -> build download URL -> curl -> unpack ->
# install -> chmod" boilerplate that every prebuilt-binary cookbook used to
# hand-roll. Crucially it derives the architecture from the already-normalized
# `node[:os_arch]` instead of re-deriving it with a shell `uname -m` case, which
# several cookbooks did and which drifted out of sync with lib's normalization.
#
# Upstreams disagree on how they spell the arch in the asset name (arm64 vs
# aarch64, x86_64 vs amd64 vs x64), so the asset file name per arch is passed
# verbatim via `arm64_name` / `x86_64_name` rather than assembled here. The tag
# is assumed to be `v<version>`, which matches every release this repo pins.
#
# The unpack strategy is inferred from the asset's extension so callers never
# describe how the binary is packed, only its name:
#   - `.tar.gz` / `.tgz` -> extract the `archive_member` binary (defaults to bin)
#   - `.gz`              -> gunzip a single compressed binary
#   - anything else      -> treat the asset as the raw executable
#
# Targets Debian/Ubuntu (installs curl via apt, writes as root). macOS variants
# of these tools come from Homebrew, so call this only from the Linux branch.
#
#   github_release_binary 'lazygit' do
#     repo           'jesseduffield/lazygit'
#     version        '0.59.0'
#     arm64_name     "lazygit_0.59.0_Linux_arm64.tar.gz"
#     x86_64_name    "lazygit_0.59.0_Linux_x86_64.tar.gz"
#     archive_member 'lazygit'
#     not_if         "lazygit --version 2>/dev/null | grep -q '0.59.0'"
#   end
define :github_release_binary,
       repo: nil,
       version: nil,
       bin_name: nil,
       arm64_name: nil,
       x86_64_name: nil,
       archive_member: nil,
       not_if: nil do
  bin = params[:bin_name] || params[:name]
  asset = node[:os_arch] == 'arm64' ? params[:arm64_name] : params[:x86_64_name]
  url = "https://github.com/#{params[:repo]}/releases/download/v#{params[:version]}/#{asset}"
  dest = "/usr/local/bin/#{bin}"
  tmp = "/tmp/#{asset}"

  unpack =
    if asset.end_with?('.tar.gz', '.tgz')
      member = params[:archive_member] || bin
      # -O streams the single member to stdout, so nothing but the binary lands
      # on disk and there is no extracted tree to clean up afterwards.
      "tar -xzf #{tmp} -O #{member} > #{dest} && chmod +x #{dest}"
    elsif asset.end_with?('.gz')
      "gunzip -c #{tmp} > #{dest} && chmod +x #{dest}"
    else
      "install -m 0755 #{tmp} #{dest}"
    end

  package 'curl' do
    user 'root'
  end

  execute "Install #{bin} from GitHub release" do
    command <<~EOC
      curl -fsSL -o #{tmp} "#{url}"
      #{unpack}
      rm -f #{tmp}
    EOC
    user 'root'
    not_if params[:not_if] if params[:not_if]
  end
end

# Install a system package with platform-specific name overrides
# Automatically handles debian/ubuntu vs darwin platform differences.
# Supports packages with the same name across platforms (e.g., ffmpeg)
# or different names (e.g., sqlite3 on debian, sqlite on darwin).
# Set `darwin_cask true` when the macOS counterpart ships as a Homebrew
# Cask (e.g., kicad, freecad, openscad) instead of a regular formula.
define :cross_platform_package, darwin_name: nil, debian_name: nil, darwin_cask: false do
  pkg = params[:name]
  if %w[ubuntu debian].include?(node[:platform])
    package(params[:debian_name] || pkg) { user 'root' }
  elsif node[:platform] == 'darwin'
    if params[:darwin_cask]
      cask_name = params[:darwin_name] || pkg
      execute "install #{cask_name} via homebrew cask" do
        command "brew install --cask #{cask_name}"
        not_if "brew list --cask #{cask_name} >/dev/null 2>&1"
      end
    else
      package(params[:darwin_name] || pkg)
    end
  else
    unsupported_platform! node[:platform]
  end
end
