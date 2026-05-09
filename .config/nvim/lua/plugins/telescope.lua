local features = require("features")

return {
  "nvim-telescope/telescope.nvim",
  enabled = features.basic_amenities,
  cmd = "Telescope",
  keys = {
    { "<leader>ff", function() require("telescope.builtin").find_files() end },
    { "<leader>fg", function() require("telescope.builtin").live_grep() end },
    { "<leader>fb", function() require("telescope.builtin").buffers() end },
    { "<leader>fh", function() require("telescope.builtin").help_tags() end },
    { "<leader>fr", "<cmd>Telescope resume<CR>", desc = "Resume the last finder." },
  },
  dependencies = { "nvim-lua/plenary.nvim" },
}
