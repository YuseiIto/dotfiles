normalized_arch = case node[:kernel][:machine]
                  when 'aarch64', 'arm64' then 'arm64'
                  else 'x86_64'
                  end

node.reverse_merge!(
  variant: 'plum',
  os_arch: normalized_arch,
  is_container: true,

  editor_features: {
    lsp: false,
    basic_amenities: false,
    lazygit: false,
    rust_dev: false,
    prisma_dev: false,
    render_md: false,
    ai: false,
    rich_presence: false
  }
)

# Shell & Terminal
include_recipe '../../cookbooks/zsh'
include_recipe '../../cookbooks/neovim'
include_recipe '../../cookbooks/base_tools'
include_recipe '../../cookbooks/direnv'
