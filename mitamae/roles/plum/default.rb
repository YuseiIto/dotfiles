normalized_arch = case node[:kernel][:machine]
                  when 'aarch64', 'arm64' then 'arm64'
                  else 'x86_64'
                  end

node.reverse_merge!(
  variant: 'plum',
  os_arch: normalized_arch,
  features: {}
)

# Shell & Terminal
include_recipe '../../cookbooks/zsh'
include_recipe '../../cookbooks/neovim'
include_recipe '../../cookbooks/base_tools'
include_recipe '../../cookbooks/direnv'
