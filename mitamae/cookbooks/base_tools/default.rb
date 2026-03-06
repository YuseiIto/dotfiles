# Essential utility. Keep it simple and minimal.

%w[
  curl
  wget
  ripgrep
  fzy
  tree
  jq
].each do |pkg|
  cross_platform_package pkg
end

# Install coreutils on macOS for GNU versions of common utilities (e.g., greadlink)
package 'coreutils' if node[:platform] == 'darwin'

include_recipe '../git'
include_recipe '../tmux'
