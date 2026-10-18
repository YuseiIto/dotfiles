-- LSPの設定のうち、各言語に固有の部分
-- メジャーなものはneovim/nvim-lspconfig にあるものを使う
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md

-- Utility function to Disable formatting capability of LSP client to avoid conflicts
local function disable_formatting(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

-- Build an LSP `cmd` that prefers `<root_dir>/.venv/bin/<bin>` over the one on PATH,
-- so a project that pins the tool as a dev dependency gets the same results as its CI.
-- Venvs outside the project (e.g. Pipenv's default) are still reached via PATH once activated.
local function venv_first_cmd(bin, args)
  return function(dispatchers, config)
    local exe = bin
    if config.root_dir then
      local venv_bin = vim.fs.joinpath(config.root_dir, '.venv', 'bin', bin)
      if vim.fn.executable(venv_bin) == 1 then
        exe = venv_bin
      end
    end
    return vim.lsp.rpc.start(vim.list_extend({ exe }, args), dispatchers, {
      cwd = config.cmd_cwd,
      env = config.cmd_env,
      detached = config.detached,
    })
  end
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

-- Pyrefly (type checking, completion, navigation)
-- https://pyrefly.org/
vim.lsp.config('pyrefly', {
  cmd = venv_first_cmd('pyrefly', { 'lsp' }),
})
vim.lsp.enable('pyrefly')

-- Ruff (lint, format, organize imports)
-- https://docs.astral.sh/ruff/editors/setup/#neovim
-- NOTE: Ruff's hover only documents noqa codes; leave hover to pyrefly.
vim.lsp.config('ruff', {
  cmd = venv_first_cmd('ruff', { 'server' }),
  on_attach = function(client, bufnr)
    client.server_capabilities.hoverProvider = false
  end,
})
vim.lsp.enable('ruff')

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
vim.lsp.config('kotlin_lsp',
  { cmd = { 'kotlin-lsp', '--stdio' },
  });

vim.lsp.enable('kotlin_lsp')

-- Rust
vim.lsp.enable('rust_analyzer')
