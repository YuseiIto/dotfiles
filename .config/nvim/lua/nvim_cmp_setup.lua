local cmp = require 'cmp'
local map = cmp.mapping

cmp.setup {
  snippet = {
    expand = function(args)
      -- cmp requires to specify a snippet engine.
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = map.preset.insert {
    ['<C-d>'] = map.scroll_docs(-4),
    ['<C-f>'] = map.scroll_docs(4),
    ['<Tab-Space>'] = map.complete(),
    ['<C-e>'] = map.abort(),
    ['<CR>'] = map.confirm { select = false },
    ['<Tab>'] = map.select_next_item(),
    ['<S-Tab>'] = map.select_prev_item(),
  },
  sources = cmp.config.sources {
    { name = 'vsnip' },
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'calc' },
  },
}
