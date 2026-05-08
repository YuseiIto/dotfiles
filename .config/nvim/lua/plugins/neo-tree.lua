local features = require("features")

return {
  "nvim-neo-tree/neo-tree.nvim",
  enabled = features.basic_amenities,
  branch = "v3.x",
  cmd = "Neotree",
  keys = {
    { "<C-n>", "<cmd>Neotree toggle reveal<CR>", desc = "Toggle file tree" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  init = function()
    -- Hijack netrw so opening a directory shows neo-tree
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  config = function()
    require("neo-tree").setup({
      filesystem = {
        hijack_netrw_behavior = "open_default",
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      window = { width = 40 },
    })
  end,
}
