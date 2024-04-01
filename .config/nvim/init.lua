-- Share clipboard with system
vim.opt.clipboard = "unnamed"

-- Remap Leader to <Space>
vim.g.mapleader = " "

vim.g.rustfmt_autosave = 1
vim.opt.number = true      -- Display lien number
vim.opt.autoindent = true  -- Indent automatically
vim.opt.hls = true         -- Highlight search
vim.opt.ignorecase = true  -- Ignore case for searching with only lowercase letters
vim.opt.smartcase = true   -- Do case-sensitive search if the pattern contains uppercase letters
vim.opt.incsearch = true   -- Search incrementally
vim.opt.errorbells = false -- Don't ring the bell when any error occourd
vim.opt.showmatch = true   -- Show matching parentheses
vim.opt.history = 10000    -- Set the number of lines to be stored in the history
vim.opt.smartindent = true -- Increase/decrease indent depending on the context
vim.opt.signcolumn = "yes" -- Always show the sign column to avoid flickering

-- Set control characters visible
vim.opt.listchars = "tab:>.,trail:_"
vim.opt.list = true

require "plugins" -- Load plugins
require "color"   -- Colors


-- Rainbow parentheses
vim.g.rainbow_active = 1


-- Enable nerdfont icons for fern
vim.g["fern#renderer"] = 'nerdfont'

-- Display hidden files on fern
vim.g["fern#default_hidden"] = 1


-- Discord Rich presense
require "presence_setup"

-- LSP Configurations
require "lsp/lsp"

-- Open lazygit
require "lazygit"

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "plugins.lua" },
  command = "PackerCompile",
})


-- Remember the place of cursor
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Open file at the last cursor position",
  pattern = "*",
  command = [[silent! normal! g`"zv]]
})



-- Compile packer configuration file when saved
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "plugins.lua" },
  command = "PackerCompile",
})


-- Disable arrow keys
vim.api.nvim_set_keymap("n", "<Up>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Down>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Left>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Right>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<Up>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<Down>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<Left>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<Right>", "<Nop>", { noremap = true })


-- Buffer operations
vim.api.nvim_set_keymap('n', '[b', ':bprevious<CR>', { silent = true })
vim.api.nvim_set_keymap('n', ']b', ':bnext<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '[B', ':bfirst<CR>', { silent = true })
vim.api.nvim_set_keymap('n', ']B', ':blast<CR>', { silent = true })


-- Tab operations
vim.cmd([[cnoreabbrev tn tabnew]])
-- Use Tab key to move between tabs
-- http://blog.remora.cx/2012/09/use-tabpage.html
vim.api.nvim_set_keymap('n', '<S-Tab>', 'gt', { noremap = true })
vim.api.nvim_set_keymap('n', '<Tab><Tab>', 'gT', { noremap = true })

for i = 1, 9, 1 do
  vim.api.nvim_set_keymap('n', '<Tab>' .. i, i .. 'gt', { noremap = true })
end
