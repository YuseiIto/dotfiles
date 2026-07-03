node.reverse_merge!(
  variant: 'palm',
  is_container: true,

  editor_features: {
    lsp: true,
    basic_amenities: true,
    lazygit: false,
    rust_dev: true,
    prisma_dev: true,
    render_md: false,
    ai: false,
    rich_presence: false
  }
)

# Infrastructure / shell env
include_recipe '../../cookbooks/shell-env'
include_recipe '../../cookbooks/bash'
include_recipe '../../cookbooks/base_tools'
include_recipe '../../cookbooks/git'
include_recipe '../../cookbooks/direnv'
include_recipe '../../cookbooks/goss'
include_recipe '../../cookbooks/dotfiles-utils'

# Languages & Runtimes
include_recipe '../../cookbooks/nodenv'
include_recipe '../../cookbooks/ruby'
include_recipe '../../cookbooks/uv'
include_recipe '../../cookbooks/rust'
include_recipe '../../cookbooks/ocaml'
include_recipe '../../cookbooks/sdkman'
include_recipe '../../cookbooks/corretto21'
include_recipe '../../cookbooks/kotlin'
include_recipe '../../cookbooks/tree-sitter'

# Build tools
include_recipe '../../cookbooks/build-essential'
include_recipe '../../cookbooks/cmake'
include_recipe '../../cookbooks/llvm'
include_recipe '../../cookbooks/binutils'

# Development Tools & LSPs
include_recipe '../../cookbooks/pylsp'
include_recipe '../../cookbooks/typescript-language-server'
include_recipe '../../cookbooks/lua-language-server'
include_recipe '../../cookbooks/terraform-ls'
include_recipe '../../cookbooks/ccls'
include_recipe '../../cookbooks/biome'
include_recipe '../../cookbooks/prisma-language-server'
include_recipe '../../cookbooks/kotlin-lsp'

# Cloud & DevOps
include_recipe '../../cookbooks/docker'
include_recipe '../../cookbooks/awscli'
include_recipe '../../cookbooks/gh'
include_recipe '../../cookbooks/google-cloud-sdk'
include_recipe '../../cookbooks/cfn-lint'
include_recipe '../../cookbooks/cloudflared'

# Networking & Security
include_recipe '../../cookbooks/nmap'
include_recipe '../../cookbooks/nikto'
include_recipe '../../cookbooks/aria2'

# Embedded & Hardware
include_recipe '../../cookbooks/arduino-cli'
include_recipe '../../cookbooks/platformio'
include_recipe '../../cookbooks/icarus-verilog'
include_recipe '../../cookbooks/avrdude'
include_recipe '../../cookbooks/openocd'

# Data & Document Processing
include_recipe '../../cookbooks/sqlite'
include_recipe '../../cookbooks/mysql-client'
include_recipe '../../cookbooks/pandoc'
include_recipe '../../cookbooks/cloc'
include_recipe '../../cookbooks/ffmpeg'
include_recipe '../../cookbooks/imagemagick'
include_recipe '../../cookbooks/graphviz'
include_recipe '../../cookbooks/huggingface-cli'
