vim.g.mapleader = " "  -- Remap Leader to <Space>
vim.opt.clipboard = "unnamed"  -- Share clipboard with system
vim.opt.number = true      -- Display line number
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
vim.opt.listchars = "tab:>.,trail:_" -- Set control characters visible
vim.opt.list = true

-- Remember the place of cursor
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Open file at the last cursor position",
  pattern = "*",
  command = [[silent! normal! g`"zv]]
})
