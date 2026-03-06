node.reverse_merge!(
  variant: 'pine',
  is_container: true,

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

include_recipe '../bamboo'

# Shell & Terminal
include_recipe '../../cookbooks/binutils'

# Networking & Security
include_recipe '../../cookbooks/cloudflared'
include_recipe '../../cookbooks/aria2'
include_recipe '../../cookbooks/nmap'
include_recipe '../../cookbooks/nikto'

# Cloud & DevOps
include_recipe '../../cookbooks/cfn-lint'

# AI & Coding Assistants
include_recipe '../../cookbooks/ollama'

# Languages & Runtimes
include_recipe '../../cookbooks/kotlin'
include_recipe '../../cookbooks/cmake'
include_recipe '../../cookbooks/ccls'
include_recipe '../../cookbooks/cloc'

# Data & Document Processing
include_recipe '../../cookbooks/ffmpeg'
include_recipe '../../cookbooks/imagemagick'
include_recipe '../../cookbooks/pandoc'

# System Utilities
include_recipe '../../cookbooks/asciinema'

# Embedded & Hardware
include_recipe '../../cookbooks/arduino-cli'
include_recipe '../../cookbooks/avrdude'
include_recipe '../../cookbooks/icarus-verilog'
include_recipe '../../cookbooks/openocd'
include_recipe '../../cookbooks/platformio'
