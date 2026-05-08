local features = require("features")

return {
  {
    "lewis6991/gitsigns.nvim",
    enabled = features.basic_amenities,
    event = { "BufReadPre", "BufNewFile" },
    config = function() require("gitsigns").setup() end,
  },
  {
    "tpope/vim-fugitive",
    enabled = features.basic_amenities,
    cmd = { "G", "Git", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse", "Gblame" },
  },
}
