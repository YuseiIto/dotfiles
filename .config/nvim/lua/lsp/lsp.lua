-- LSP の設定
require "lsp/languages"


-- `:Format` コマンドでフォーマットしたい
local function fn_format()
  vim.lsp.buf.format({ async = false })
end
vim.api.nvim_create_user_command("Format", fn_format, { nargs = 0 })

--[[
  NOTE: `gr` is intentionally left unmapped: Neovim 0.11 ships built-in LSP mappings
  under the `gr` prefix (grr/grn/gra/gri/grt). Mapping `gr` directly would
  shadow them and force a `timeoutlen` wait. Use the built-in `grr` for
  references instead.
--]]

vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.format()<CR>')
vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
vim.keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')
vim.keymap.set('n', 'g]', function() vim.diagnostic.jump({ count = 1, float = true }) end)
vim.keymap.set('n', 'g[', function() vim.diagnostic.jump({ count = -1, float = true }) end)
