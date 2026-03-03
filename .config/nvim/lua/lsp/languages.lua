-- LSPの設定のうち、各言語に固有の部分
-- メジャーなものはneovim/nvim-lspconfig にあるものを使う
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md

-- Utility function to Disable formatting capability of LSP client to avoid conflicts
local function disable_formatting(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

-- Lua Language Server
-- https://github.com/LuaLS/lua-language-server
vim.lsp.enable('lua_ls')

-- ocamllsp
-- https://github.com/ocaml/ocaml-lsp
vim.lsp.enable('ocamllsp')

-- clangd
vim.lsp.enable('clangd')

-- terraformls
vim.lsp.enable('terraformls')

-- python-lsp-server
-- https://github.com/python-lsp/python-lsp-server
vim.lsp.enable('pylsp')

vim.lsp.enable('nil_ls')

-- ts_ls
-- Disable formatting for ts_ls (Leave it to biome)
vim.lsp.config('ts_ls', {
  on_attach = disable_formatting,
})
vim.lsp.enable('ts_ls')

-- jsonls
-- Disable formatting for jsonls (Leave it to biome)
vim.lsp.config('ts_ls', {
  on_attach = disable_formatting,
})
vim.lsp.enable('jsonls')

-- biome
vim.lsp.enable('biome')

-- prismals
-- https://github.com/prisma/language-tools
vim.lsp.enable('prismals')

-- Rust
vim.lsp.enable('rust_analyzer')
