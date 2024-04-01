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
    use { 'rust-lang/rust.vim',
      config = function()
        vim.g.rustfmt_autosave = 1
      end
    }
    -- OneDark Appearance theme
    use { 'joshdick/onedark.vim',
      requires = 'sheerun/vim-polyglot' }

    -- beautiful statusbar
    use 'itchyny/lightline.vim'

    -- GitHub Copilot
    use 'github/copilot.vim'

    -- todo-comments
    use { 'folke/todo-comments.nvim',
      config = function()
        require('todo-comments').setup()
      end,
      requires = { 'nvim-lua/plenary.nvim' }
    }

    -- Rainbow parentheses
    use { 'luochen1990/rainbow',
      config = function()
        vim.g.rainbow_active = 1
      end
    }

    -- Close parentheses automatically
    use { 'windwp/nvim-autopairs',
      config = function()
        require('nvim-autopairs').setup()
      end
    }

    -- Display git status
    use 'airblade/vim-gitgutter'

    -- Powerful fuzzy search and navigation
    use { 'nvim-telescope/telescope.nvim',
      tag = '*',
      requires = { 'nvim-lua/plenary.nvim' },
      config = function()
        --  Find files using Telescope command-line sugar
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
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

        -- Display hidden files on fern
        vim.g["fern#default_hidden"] = 1
      end
    }


    -- Display fit status on fern file tree
    use 'lambdalisue/fern-git-status.vim'
    -- For richer icon at fern
    use { 'lambdalisue/fern-renderer-nerdfont.vim',
      requires = { 'lambdalisue/nerdfont.vim' },
      config = function()
        vim.g["fern#renderer"] = 'nerdfont' -- Enable nerdfont icons for fern
      end
    }

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
    use { 'lambdalisue/fern-hijack.vim',
      requires = "lambdalisue/fern.vim" }

    -- Display terminal in easy manner
    use { 'akinsho/toggleterm.nvim', tag = '*' }

    -- Prisma
    use 'prisma/vim-prisma'

    -- Discord Rich presense
    use { 'andweeb/presence.nvim',
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
      end
    }

    -- Language Server Configurations
    use 'neovim/nvim-lspconfig'

    use {
      'hrsh7th/nvim-cmp',
      config = function() require 'nvim_cmp_setup' end,
      requires = {
        'hrsh7th/cmp-nvim-lsp', -- LSP source for nvim-cmp
        'hrsh7th/cmp-nvim-lua'  -- Neovim Lua source for nvim-cmp
      }
    }
  end)
