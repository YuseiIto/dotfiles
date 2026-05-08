local features = require("features")

return {
  "folke/todo-comments.nvim",
  enabled = features.basic_amenities,
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function() require("todo-comments").setup() end,
}
