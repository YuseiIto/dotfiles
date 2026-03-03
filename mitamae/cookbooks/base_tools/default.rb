# Essential utility. Keep it simple and minimal.

# packages that are named the same across platforms.
base_packages = %w[
  curl
  wget
  tmux
  ripgrep
  fzy
  tree
  jq
]

base_packages.each do |pkg|
  if ['ubuntu', 'debian'].include?(node[:platform])
    package pkg do
      user 'root'
    end
  else
    # macOS, Arch Linux
    package pkg
  end
end

# Install coreutils on macOS for GNU versions of common utilities (e.g., greadlink)
package 'coreutils' if node[:platform] == 'darwin'

include_recipe '../git'
