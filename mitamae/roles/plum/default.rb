node.reverse_merge!(
  variant: 'plum',
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
