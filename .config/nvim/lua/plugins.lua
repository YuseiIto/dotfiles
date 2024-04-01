-- Install packer automatically
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

local packer = require("packer")

packer.startup(
  function(use)
    use 'wbthomason/packer.nvim'
    use 'rust-lang/rust.vim'
    -- OneDark Appearance theme
    use 'joshdick/onedark.vim'
    use 'sheerun/vim-polyglot'

    -- beautiful statusbar
    use 'itchyny/lightline.vim'

    -- GitHub Copilot
    use 'github/copilot.vim'

    -- Plenary - common utility functions. Required for todo-comments and telescpose
    use 'nvim-lua/plenary.nvim'

    -- todo-comments
    use { 'folke/todo-comments.nvim',
      config = function()
        require('todo-comments').setup()
      end
    }

    -- Rainbow parentheses
    use 'luochen1990/rainbow'

    -- Close parentheses automatically
    use { 'windwp/nvim-autopairs',
      config = function()
        require('nvim-autopairs').setup()
      end
    }

    -- Display git status
    use 'airblade/vim-gitgutter'

    -- Powerful fuzzy search and navigation
    use { 'nvim-telescope/telescope.nvim', tag = '0.1.0'
    ,
      config = function()
        --  Find files using Telescope command-line sugar
        vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files hidden=true<cr>', { noremap = true })
        vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { noremap = true })
        vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { noremap = true })
        vim.api.nvim_set_keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { noremap = true })
      end
    }

    -- Git commands from vim (add, commit, pluh, blame etc...)
    use 'tpope/vim-fugitive'

    -- Directory tree that is said to be faster than nerdtree
    use { 'lambdalisue/fern.vim',
      config = function()
        --  Show file tree with Ctrl+n
        vim.api.nvim_set_keymap('n', '<C-n>', ':Fern . -reveal=% -drawer -toggle -width=40<CR>',
          { noremap = true, silent = true })
      end
    }


    -- Display fit status on fern file tree
    use 'lambdalisue/fern-git-status.vim'
    -- For richer icon at fern
    use 'lambdalisue/nerdfont.vim'
    use 'lambdalisue/fern-renderer-nerdfont.vim'
    use {
      'lambdalisue/glyph-palette.vim',
      config = function()
        -- Enable individual color for fern icons
        vim.api.nvim_create_augroup("my-glyph-palette", {
          clear = true
        })

        vim.api.nvim_create_autocmd("FileType", {
          pattern = "fern",
          command = "call glyph_palette#apply()",
          group = "my-glyph-palette"
        })

        vim.api.nvim_create_autocmd("FileType", {
          pattern = "nerdtree,startify",
          command = "call glyph_palette#apply()",
          group = "my-glyph-palette"
        })
      end }

    -- Use fern instead of default filer
    use 'lambdalisue/fern-hijack.vim'

    -- Display terminal in easy manner
    use { 'akinsho/toggleterm.nvim', tag = '*' }

    -- Prisma
    use 'prisma/vim-prisma'

    -- Discord Rich presense
    use 'andweeb/presence.nvim'

    -- Language Server Configurations
    use 'neovim/nvim-lspconfig'
  end)
