local features = require("features")

return {
  {
    "github/copilot.vim",
    enabled = features.ai,
    event = "InsertEnter",
  },
  {
    "olimorris/codecompanion.nvim",
    enabled = features.ai,
    cmd = { "CodeCompanion", "CodeCompanionActions", "CodeCompanionChat" },
    keys = {
      { "<leader>fa", "<cmd>CodeCompanionActions<CR>", desc = "CodeCompanion actions" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "copilot",
            roles = {
              llm = function(adapter)
                return "  CodeCompanion (" .. adapter.formatted_name .. ")"
              end,
              user = "  Me",
            },
          },
          inline = { adapter = "copilot" },
          agent = { adapter = "copilot" },
        },
        display = { chat = { show_header_separator = true } },
      })
      vim.cmd([[cab cc CodeCompanion]])
    end,
  },
}
