local features = require("features")

return {
  "akinsho/toggleterm.nvim",
  enabled = features.basic_amenities,
  version = "*",
  cmd = { "ToggleTerm", "ToggleTermToggleAll" },
  keys = { "<leader>g" },
  config = function() require("toggleterm").setup() end,
}
