local features = require("features")

return {
  "akinsho/toggleterm.nvim",
  enabled = features.basic_amenities,
  version = "*",
  cmd = { "ToggleTerm", "ToggleTermToggleAll" },
  -- Only register the lazygit binding on roles that actually install lazygit;
  -- otherwise <leader>g would launch a missing binary.
  keys = features.lazygit and { "<leader>g" } or nil,
  config = function()
    require("toggleterm").setup()

    if features.lazygit then
      local Terminal = require('toggleterm.terminal').Terminal
      local lazygit  = Terminal:new({
        cmd = "lazygit",
        hidden = true,
        direction = "float",
      })

      function _lazygit_toggle()
        lazygit:toggle()
      end

      vim.keymap.set("n", "<leader>g", "<cmd>lua _lazygit_toggle()<CR>", { silent = true, desc= "Open lazygit on floating window."})
    end
  end,
}
