node.reverse_merge!(
  variant: 'belle',
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

# Networking & Security
include_recipe '../../cookbooks/cloudflared'
include_recipe '../../cookbooks/aria2'
include_recipe '../../cookbooks/nmap'
include_recipe '../../cookbooks/nikto'

# Cloud & DevOps
include_recipe '../../cookbooks/awscli'
include_recipe '../../cookbooks/cfn-lint'
include_recipe '../../cookbooks/gh'

# AI & Coding Assistants
include_recipe '../../cookbooks/ollama'
include_recipe '../../cookbooks/huggingface-cli'
include_recipe '../../cookbooks/aider'
include_recipe '../../cookbooks/claude-code'
include_recipe '../../cookbooks/gemini-cli'
include_recipe '../../cookbooks/opencode'

# Languages & Runtimes
include_recipe '../../cookbooks/kotlin'
include_recipe '../../cookbooks/ocaml'
include_recipe '../../cookbooks/lua-language-server'

# Build & Development Tools
include_recipe '../../cookbooks/cmake'
include_recipe '../../cookbooks/ccls'
include_recipe '../../cookbooks/cloc'

# Data & Document Processing
include_recipe '../../cookbooks/ffmpeg'
include_recipe '../../cookbooks/imagemagick'
include_recipe '../../cookbooks/pandoc'
include_recipe '../../cookbooks/sqlite'
include_recipe '../../cookbooks/mysql-client'

# System Utilities
include_recipe '../../cookbooks/asciinema'

# Embedded & Hardware
include_recipe '../../cookbooks/arduino-cli'
include_recipe '../../cookbooks/arduino-ide'
include_recipe '../../cookbooks/avrdude'
include_recipe '../../cookbooks/icarus-verilog'
include_recipe '../../cookbooks/openocd'
include_recipe '../../cookbooks/platformio'

# macOS GUI Specific Features
include_recipe '../../cookbooks/feature_macos_communication'
include_recipe '../../cookbooks/feature_macos_fonts'
include_recipe '../../cookbooks/feature_macos_media'
include_recipe '../../cookbooks/feature_macos_utilities'
include_recipe '../../cookbooks/feature_macos_writing'
include_recipe '../../cookbooks/firefox'
include_recipe '../../cookbooks/google-chrome'
include_recipe '../../cookbooks/kicad'
include_recipe '../../cookbooks/freecad'
include_recipe '../../cookbooks/openscad'
include_recipe '../../cookbooks/processing'
include_recipe '../../cookbooks/postico'
include_recipe '../../cookbooks/stoplight-studio'
include_recipe '../../cookbooks/flatcam'

# Development Tools & LSPs
include_recipe '../../cookbooks/llvm'
include_recipe '../../cookbooks/terraform-ls'
include_recipe '../../cookbooks/pylsp'
include_recipe '../../cookbooks/typescript-language-server'
include_recipe '../../cookbooks/biome'
include_recipe '../../cookbooks/prisma-language-server'
include_recipe '../../cookbooks/goss'
