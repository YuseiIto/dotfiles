-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local features = require "features"

require "base"
require "key"      -- Key bindings
require("lazy").setup("plugins", {
  -- No bundled plugin currently requires luarocks. Re-enable if a future
  -- plugin needs it (the :checkhealth will tell you).
  rocks = { enabled = false },
})
require "color"    -- Colors

if features.lsp then
require "lsp/lsp"  -- LSP Configurations
end
