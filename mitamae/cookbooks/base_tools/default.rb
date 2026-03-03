# Essential utility. Keep it simple and minimal.

# packages that are named the same across platforms.
base_packages = %w(
  curl
  wget
  tmux
  ripgrep
  fzy
  tree
  jq
)

base_packages.each do |pkg|
  if node[:platform] == "ubuntu" || node[:platform] == "debian"
    package pkg do
      user "root"
    end
  else
    # macOS, Arch Linux
    package pkg
  end
end

# Install coreutils on macOS for GNU versions of common utilities (e.g., greadlink)
if node[:platform] == "darwin"
  package "coreutils"
end

include_recipe "../git"
