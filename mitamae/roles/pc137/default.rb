node.reverse_merge!(
  variant: 'pc137',
  is_container: false,

  editor_features: {
    lsp: true,
    basic_amenities: true,
    lazygit: true,
    rust_dev: true,
    prisma_dev: true,
    render_md: true,
    ai: true,
    rich_presence: true
  }
)

# Infrastructure
include_recipe '../../cookbooks/homebrew'
include_recipe '../../cookbooks/git'
include_recipe '../../cookbooks/rust'
include_recipe '../../cookbooks/uv'
include_recipe '../../cookbooks/nodenv'

# Shell & Terminal
include_recipe '../../cookbooks/zsh'
include_recipe '../../cookbooks/neovim'
include_recipe '../../cookbooks/base_tools'
include_recipe '../../cookbooks/binutils'
include_recipe '../../cookbooks/starship'
include_recipe '../../cookbooks/direnv'
include_recipe '../../cookbooks/lazygit'
include_recipe '../../cookbooks/alacritty'

# Networking
include_recipe '../../cookbooks/cloudflared'

# Cloud & DevOps
include_recipe '../../cookbooks/awscli'
include_recipe '../../cookbooks/cfn-lint'
include_recipe '../../cookbooks/gh'
include_recipe '../../cookbooks/docker'

# AI & Coding Assistants
include_recipe '../../cookbooks/ollama'
include_recipe '../../cookbooks/huggingface-cli'
include_recipe '../../cookbooks/aider'
include_recipe '../../cookbooks/claude-code'
include_recipe '../../cookbooks/gemini-cli'
include_recipe '../../cookbooks/opencode'

# Development Tools & LSPs
include_recipe '../../cookbooks/llvm'
include_recipe '../../cookbooks/terraform-ls'
include_recipe '../../cookbooks/pylsp'
include_recipe '../../cookbooks/typescript-language-server'
include_recipe '../../cookbooks/biome'
include_recipe '../../cookbooks/prisma-language-server'
include_recipe '../../cookbooks/lua-language-server'
include_recipe '../../cookbooks/cloc'
include_recipe '../../cookbooks/goss'

# macOS GUI
include_recipe '../../cookbooks/feature_macos_fonts'
include_recipe '../../cookbooks/slack'
include_recipe '../../cookbooks/firefox'
include_recipe '../../cookbooks/google-chrome'
include_recipe '../../cookbooks/postico'
include_recipe '../../cookbooks/stoplight-studio'
include_recipe '../../cookbooks/ovice'
