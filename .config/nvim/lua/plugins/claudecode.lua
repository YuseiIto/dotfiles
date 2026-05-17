local features = require("features")

return {
  "coder/claudecode.nvim",
  enabled = features.ai,
  cmd = {
    "ClaudeCode",
    "ClaudeCodeSend",
    "ClaudeCodeAdd",
    "ClaudeCodeFocus",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
  },
  keys = {
    { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer to Claude" },
  },
  opts = {
    terminal = {
      provider = "none",
    },
  },
}
