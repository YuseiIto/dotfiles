require "base"
require "key" -- Key bindings
require "plugins" -- Load plugins
require "color"   -- Colors
require "presence"  -- Discord Rich presense
require "lsp/lsp"  -- LSP Configurations
require "lazygit"  -- Open lazygit

-- Compile packer configuration file when saved
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "plugins.lua" },
  command = "PackerCompile",
})
