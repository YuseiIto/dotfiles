-- LSPの設定のうち、各言語に固有の部分
-- メジャーなものはneovim/lspconfig にあるものを使う
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

local lspconfig = require("lspconfig")

-- Lua Language Server
-- https://github.com/LuaLS/lua-language-server
lspconfig.lua_ls.setup {}

-- ocamllsp
-- https://github.com/ocaml/ocaml-lsp
lspconfig.ocamllsp.setup {}

-- ccls
-- https://github.com/MaskRay/ccls
lspconfig.ccls.setup {}

-- terraform-lsp
-- https://github.com/juliosueiras/terraform-lsp
lspconfig.terraform_lsp.setup{}

-- python-lsp-server
-- https://github.com/python-lsp/python-lsp-server
lspconfig.pylsp.setup {}


lspconfig.nil_ls.setup {}
