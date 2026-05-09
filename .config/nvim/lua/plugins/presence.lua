local features = require("features")

return {
  "andweeb/presence.nvim",
  enabled = features.rich_presence,
  event = "VeryLazy",
  config = function()
    require("presence").setup({
      blacklist           = {},
      buttons             = false,
      show_time           = false,
      editing_text        = "Editing file",
      file_explorer_text  = "Browsing file",
      git_commit_text     = "Committing changes",
      plugin_manager_text = "Managing plugins",
      reading_text        = "Reading file",
      workspace_text      = "Working on project",
      line_number_text    = "",
    })
  end,
}
