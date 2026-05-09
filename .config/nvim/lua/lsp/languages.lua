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

-- ts_ls
-- Disable formatting for ts_ls (Leave it to biome)
vim.lsp.config('ts_ls', {
  on_attach = disable_formatting,
})
vim.lsp.enable('ts_ls')

-- biome
-- Fall back to the current file's directory so biome LSP attaches even in
-- projects without biome.json (e.g. ad-hoc JSON editing).
vim.lsp.config('biome', {
  root_dir = function(bufnr, cb)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local markers = vim.fs.find(
      { 'biome.json', 'biome.jsonc', 'package.json', '.git' },
      { upward = true, path = vim.fs.dirname(fname) }
    )
    if #markers > 0 then
      cb(vim.fs.dirname(markers[1]))
    else
      cb(vim.fs.dirname(fname))
    end
  end,
})
vim.lsp.enable('biome')

-- prismals
-- https://github.com/prisma/language-tools
vim.lsp.enable('prismals')

-- Kotlin LSP
-- https://github.com/Kotlin/kotlin-lsp
vim.lsp.enable('kotlin_lsp')

-- Rust
vim.lsp.enable('rust_analyzer')
