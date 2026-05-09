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
        filtered_items = {
          -- Hide gitignored files to reduce libuv watchers and avoid EMFILE errors.
          -- Press 'H' to toggle visibility when needed.
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            ".git",
          },
        },
      }
    })
  end,
}
