-- Configure 24-bit true color
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.cmd("colorscheme onedark")

-- Configure lightline to use onedark
vim.g.lightline = { colorscheme = 'onedark' }
