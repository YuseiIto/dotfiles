local features = require("features")

return {
  {
    "neovim/nvim-lspconfig",
    enabled = features.lsp,
    lazy = false,
    dependencies = { "Saghen/blink.cmp" },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })
    end,
  },
  {
    "Saghen/blink.cmp",
    enabled = features.lsp,
    version = "1.*",
    -- No lazy-load event: blink.cmp is a dependency of nvim-lspconfig (which is
    -- `lazy = false`) and its capabilities are required in that plugin's
    -- config, so it always loads at startup. An `event` here would be a no-op.
    opts = {
      keymap = {
        preset = "default",
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
        ["<C-f>"] = { "scroll_documentation_up", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
      },
      sources = {
        default = { "lsp", "path", "buffer" },
      },
      completion = {
        list = { selection = { preselect = false, auto_insert = true } },
      },
    },
  },
}
