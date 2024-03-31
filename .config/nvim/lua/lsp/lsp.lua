-- LSP の設定
require "lsp/languages"


-- `:Format` コマンドでフォーマットしたい
local function fn_format()
  vim.lsp.buf.format({ async = false })
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function()
    vim.api.nvim_create_user_command("Format", fn_format, { nargs = 0 })
  end
})
