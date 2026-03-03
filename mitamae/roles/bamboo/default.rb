normalized_arch = case node[:kernel][:machine]
                  when 'aarch64', 'arm64' then 'arm64'
                  else 'x86_64'
                  end

node.reverse_merge!(
  variant: 'bamboo',
  os_arch: normalized_arch,
  editor_features: {
    lsp: true,
    basic_amenities: true,
    lazygit: true,
    rust_dev: true,
    prisma_dev: true,
    render_md: false,
    ai: true,
    rich_presence: false
  }
)

# Infrastructure
include_recipe '../../cookbooks/git'
include_recipe '../../cookbooks/rust'
include_recipe '../../cookbooks/uv'
include_recipe '../../cookbooks/nodenv'

# Shell & Terminal
include_recipe '../../cookbooks/zsh'
include_recipe '../../cookbooks/neovim'
include_recipe '../../cookbooks/base_tools'
include_recipe '../../cookbooks/starship'
include_recipe '../../cookbooks/direnv'
include_recipe '../../cookbooks/lazygit'

# Cloud & DevOps
include_recipe '../../cookbooks/awscli'
include_recipe '../../cookbooks/gh'

# AI & Coding Assistants
include_recipe '../../cookbooks/huggingface-cli'
include_recipe '../../cookbooks/aider'
include_recipe '../../cookbooks/claude-code'
include_recipe '../../cookbooks/gemini-cli'
include_recipe '../../cookbooks/opencode'

# Data & Document Processing
include_recipe '../../cookbooks/sqlite'
include_recipe '../../cookbooks/mysql-client'

# Development Tools & LSPs
include_recipe '../../cookbooks/llvm'
include_recipe '../../cookbooks/terraform-ls'
include_recipe '../../cookbooks/pylsp'
include_recipe '../../cookbooks/typescript-language-server'
include_recipe '../../cookbooks/biome'
include_recipe '../../cookbooks/prisma-language-server'
include_recipe '../../cookbooks/ocaml'
include_recipe '../../cookbooks/lua-language-server'
