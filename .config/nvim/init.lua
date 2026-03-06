local features = require "features"

require "base"
require "key"      -- Key bindings
require "plugins"  -- Load plugins
require "color"    -- Colors

if features.rich_presence then
require "presence" -- Discord Rich presence
end

if features.lsp then
require "lsp/lsp"  -- LSP Configurations
end

if features.lazygit then
require "lazygit"  -- Open lazygit
end

-- Compile packer configuration file when saved
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "plugins.lua" },
  command = "PackerCompile",
})
