"Share clipboard with system
set clipboard=unnamed

" vim-plug autoinstall
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.config/nvim/plugged') " Languages
  Plug 'rust-lang/rust.vim'
  
  " LSP
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  " OneDark Appearance theme
  Plug 'joshdick/onedark.vim'
  Plug 'sheerun/vim-polyglot'
  
  " beautiful statusbar
  Plug 'itchyny/lightline.vim'  
  
  " GitHub Copilot
  Plug 'github/copilot.vim'

  " Plenary - common utility functions. Required for todo-comments and telescpose
  Plug 'nvim-lua/plenary.nvim'

  " todo-comments 
  Plug 'folke/todo-comments.nvim'
  
  " Rainbow parentheses
  Plug 'luochen1990/rainbow'

  " Close parentheses automatically
  Plug 'windwp/nvim-autopairs'
  " Display git status
  Plug 'airblade/vim-gitgutter'
  
  " Powerful fuzzy search and navigation
  Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }

  " Git commands from vim (add, commit, pluh, blame etc...)
  Plug 'tpope/vim-fugitive'

  " Directory tree that is said to be faster than nerdtree
  Plug 'lambdalisue/fern.vim'
  " Display fit status on fern file tree
  Plug 'lambdalisue/fern-git-status.vim'
  " For richer icon at fern
  Plug 'lambdalisue/nerdfont.vim'
  Plug 'lambdalisue/fern-renderer-nerdfont.vim'
  Plug 'lambdalisue/glyph-palette.vim'

  " Use fern instead of default filer
  Plug 'lambdalisue/fern-hijack.vim'
  
  " Display terminal in easy manner
  Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}
 call plug#end()

filetype plugin indent on

" Run rustfmt before save
let g:rustfmt_autosave = 1

set number "Display line number 
set autoindent "Indent
set hls "Highlight search
set ignorecase " Ignore case for searching with only lowercase letters
set smartcase " Do case-sensitive search if the pattern contains uppercase letters
set incsearch " Search incrementally
set noerrorbells " Don't ring the bell when any error occourd
set showmatch " Show matching parentheses
set history=10000 " Set the number of lines to be stored in the history
set smartindent "Increase/decrease indent depending on the context
set signcolumn=yes " Always show the sign column to avoid flickering

"Set control characters visible
set listchars=tab:>.,trail:_
set list

" Remember the place of cursor
if has("autocmd")
  augroup redhat
    " In text files, always limit the width of text to 78 characters
    autocmd BufRead *.txt set tw=78
    " When editing a file, always jump to the last cursor position
    autocmd BufReadPost *
    \ if line("'\"") > 0 && line ("'\"") <= line("$") |
    \   exe "normal! g'\"" |
    \ endif
  augroup END
endif

" Configure 24-bit true color
if (has("termguicolors"))
  set termguicolors
endif

" Configure Color scheme
syntax on
colorscheme koehler

" Configure lightline to use onedark
let g:lightline = { 'colorscheme': 'onedark' }

" Coc
source ~/.config/nvim/coc.vim

" todo comments

lua << EOF
  require("todo-comments").setup {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
EOF

" Rainbow parentheses
let g:rainbow_active = 1

" Close parentheses automatically
lua << EOF
require("nvim-autopairs").setup {}
EOF

" Enable nerdfont icons for fern
let g:fern#renderer = 'nerdfont'

" Display hidden files on fern
let g:fern#default_hidden = 1

" Enable individual color for fern icons
augroup my-glyph-palette
  autocmd! *
  autocmd FileType fern call glyph_palette#apply()
  autocmd FileType nerdtree,startify call glyph_palette#apply()
augroup END

" Show file tree with Ctrl+n
nnoremap <C-n> :Fern . -reveal=% -drawer -toggle -width=40<CR>

" Disable arrow keys
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>
inoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>

" Telescope
nnoremap <leader>gb <cmd>Telescope git_branches theme=get_dropdown<cr>
nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <C-g> <cmd>Telescope live_grep<cr>

"Remap Copilot tab to Ctrl-J to avoid conflict with coc
imap <silent><script><expr> <C-c> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

" Toggle terminal
" It must be explicitly set up
" https://github.com/akinsho/toggleterm.nvim#setup
lua require("toggleterm").setup()

command T ToggleTerm<CR>
command Tt ToggleTerm direction="tab"<CR>
command Tf ToggleTerm direction="float"<CR>

" Open lazygit
command Lg :TermExec direction=tab cmd=lazygit&&exit<CR> go_back=0

lua require('lazygit')
