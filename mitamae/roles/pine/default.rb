normalized_arch = case node[:kernel][:machine]
                  when 'aarch64', 'arm64' then 'arm64'
                  else 'x86_64'
                  end

node.reverse_merge!(
  variant: 'pine',
  os_arch: normalized_arch,
  features: {}
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
include_recipe '../../cookbooks/binutils'
include_recipe '../../cookbooks/starship'
include_recipe '../../cookbooks/direnv'
include_recipe '../../cookbooks/lazygit'

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
include_recipe '../../cookbooks/avrdude'
include_recipe '../../cookbooks/icarus-verilog'
include_recipe '../../cookbooks/openocd'
include_recipe '../../cookbooks/platformio'
