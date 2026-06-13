node.reverse_merge!(
  variant: 'claude',
  is_container: true,
  claude_code: {
    install_cli: false
  },

  editor_features: {
    lsp: false,
    basic_amenities: false,
    lazygit: false,
    rust_dev: false,
    prisma_dev: false,
    render_md: false,
    ai: true,
    rich_presence: false
  }
)

# AI & Coding Assistants
# Thin role for Claude Code hosted environments: claude is already installed there, so the CLI
# install is skipped (claude_code.install_cli = false) and we only symlink ~/.claude config.
include_recipe '../../cookbooks/claude-code'
