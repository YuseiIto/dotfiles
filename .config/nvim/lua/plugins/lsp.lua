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
