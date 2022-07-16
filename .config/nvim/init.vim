"Share clipboard with system
set clipboard=unnamed

" vim-plug autoinstall
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged')
  Plug 'rust-lang/rust.vim'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'joshdick/onedark.vim'
  Plug 'sheerun/vim-polyglot'
  Plug 'itchyny/lightline.vim'
  Plug 'github/copilot.vim'
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
colorscheme onedark

" Configure lightline to use onedark
let g:lightline = { 'colorscheme': 'onedark' }

source ~/.config/nvim/coc.vim
