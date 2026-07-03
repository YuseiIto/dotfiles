local features = require("features")

return {
  "nvim-neo-tree/neo-tree.nvim",
  enabled = features.basic_amenities,
  branch = "v3.x",
  lazy = false,
  keys = {
    { "<C-n>", "<cmd>Neotree toggle reveal<CR>", desc = "Toggle file tree" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      -- Quit neovim when neo-tree window is the last one remaining.
      close_if_last_window = true,
      window = {
        mappings = {
          ["v"] = "open_vsplit",
          ["l"] = "open",
          ["h"] = "close_node"
        }
      },
      filesystem = {
        -- Let the tree focus on the file opened in the current buffer.
        follow_current_file = {
          enabled = true,
        },
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
