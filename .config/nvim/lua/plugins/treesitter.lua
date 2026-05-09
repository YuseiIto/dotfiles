local features = require("features")

return {
  "nvim-treesitter/nvim-treesitter",
  enabled = features.basic_amenities,
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local langs = {
      "bash", "c", "cpp", "css", "diff", "dockerfile", "git_config",
      "gitcommit", "gitignore", "go", "html", "javascript", "json",
      "kotlin", "lua", "luadoc", "make", "markdown",
      "markdown_inline", "ocaml", "prisma", "python", "query", "regex",
      "ruby", "rust", "terraform", "toml", "tsx", "typescript", "vim",
      "vimdoc", "yaml",
    }

    require("nvim-treesitter").install(langs)

    local group = vim.api.nvim_create_augroup("dotfiles-treesitter", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = langs,
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
