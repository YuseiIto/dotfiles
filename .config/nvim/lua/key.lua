-- Disable arrow keys
vim.keymap.set({ "n", "i" }, "<Up>", "<Nop>", { desc = "Disable <Up>" })
vim.keymap.set({ "n", "i" }, "<Down>", "<Nop>", { desc = "Disable <Down>" })
vim.keymap.set({ "n", "i" }, "<Left>", "<Nop>", { desc = "Disable <Left>" })
vim.keymap.set({ "n", "i" }, "<Right>", "<Nop>", { desc = "Disable <Right>" })

-- Buffer operations
vim.keymap.set('n', '[b', '<cmd>bprevious<CR>', { silent = true, desc = "Go to previous buffer" })
vim.keymap.set('n', ']b', '<cmd>bnext<CR>', { silent = true, desc = "Go to next buffer" })
vim.keymap.set('n', '[B', '<cmd>bfirst<CR>', { silent = true, desc = "Go to first buffer" })
vim.keymap.set('n', ']B', '<cmd>blast<CR>', { silent = true, desc = "Go to last buffer" })

-- Tab operations
vim.cmd([[cnoreabbrev tn tabnew]])
-- Avoid using <Tab> as a mapping prefix: in a terminal <Tab> and <C-i> share
-- the same keycode, so prefixing with <Tab> shadows <C-i> (jumplist forward)
-- behind a timeoutlen wait. Use bracket pairs, consistent with [b/]b above.
vim.keymap.set('n', '[t', 'gT', { silent = true, desc = "Go to previous tab" })
vim.keymap.set('n', ']t', 'gt', { silent = true, desc = "Go to next tab" })

for i = 1, 9, 1 do
  vim.keymap.set('n', '<leader>' .. i, i .. 'gt', { desc = string.format("Jump to %d-th tab.", i) })
end

vim.keymap.set('t', '<C-q>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
