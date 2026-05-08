local features = require("features")

return {
  "MeanderingProgrammer/render-markdown.nvim",
  enabled = features.basic_amenities and features.render_md,
  ft = { "markdown", "codecompanion" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "echasnovski/mini.nvim",
  },
  config = function()
    require("render-markdown").setup({
      file_types = { "markdown", "codecompanion" },
    })
    vim.treesitter.language.register("markdown", "codecompanion")
  end,
}
