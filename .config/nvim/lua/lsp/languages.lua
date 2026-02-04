-- LSPの設定のうち、各言語に固有の部分
-- メジャーなものはneovim/nvim-lspconfig にあるものを使う
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md

-- Lua Language Server
-- https://github.com/LuaLS/lua-language-server
vim.lsp.enable('lua_ls')

-- ocamllsp
-- https://github.com/ocaml/ocaml-lsp
vim.lsp.enable('ocamllsp')

-- ccls
-- https://github.com/MaskRay/ccls
vim.lsp.enable('ccls')

-- terraform-lsp
-- https://github.com/juliosueiras/terraform-lsp
vim.lsp.enable('terraform_lsp')

-- python-lsp-server
-- https://github.com/python-lsp/python-lsp-server
vim.lsp.enable('pylsp')


vim.lsp.enable('nil_ls')

vim.lsp.enable('biome')

vim.lsp.enable('ts_ls')

vim.lsp.enable('jsonls')

-- prismals
-- https://github.com/prisma/language-tools
vim.lsp.enable('prismals')

-- Rust
vim.lsp.enable('rust_analyzer')
