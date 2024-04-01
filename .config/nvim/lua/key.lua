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
