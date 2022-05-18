" -------------------- Plugins (VimPlug) ------------------------------------
call plug#begin('$XDG_CONFIG_HOME/nvim/plugged')
Plug 'junegunn/limelight.vim' " Syntax
Plug 'morhetz/gruvbox' " Color-schemes
Plug 'aca/completion-tabnine', { 'do': './install.sh' }
call plug#end()
colorscheme gruvbox 

" -------------------- General Settings -------------------------------------
set noerrorbells visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=
set encoding=UTF-8
filetype plugin indent on " Filetype detection
"syntax on
set autoread " Reopen modified files
set wildmenu " Invoke completion
set number relativenumber " Relative line numbers
set numberwidth=3
"set spelllang=en_us " 
"set spell
set backspace=indent,eol,start
set noruler
set confirm
set shiftwidth=4
set smartindent
set autoindent
set tabstop=4
set softtabstop=4
set expandtab
set hls is
set ic
set laststatus=2
set cmdheight=1
set colorcolumn=81
set cursorline
set noemoji
set cpoptions+=n

" -------------------- Status-line ------------------------------------------
set statusline= "Left align
set statusline+=%#Folded#
set statusline+=\ %M "Modified flag
set statusline+=\ %y "File type
set statusline+=\ %r "Read only flag
set statusline+=\ %F "Full file path
set statusline+=%= "Right align
set statusline+=%#Search#
set statusline+=\ %c:%l/%L
set statusline+=\ %p%% "Percentage of file
set statusline+=\ [%n] "Buffer number

" -------------------- Color Settings ---------------------------------------
set background=dark
hi statusline guibg=DarkGrey ctermfg=8
highlight LineNr ctermfg=darkgrey "Line number color
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctremfg = 240

" -------------------- Functions --------------------------------------------
autocmd! bufwritepost $MYVIMRC source $MYVIMRC " Auto refresh init.vim
augroup line_return " Return to the same line when you reopen a file
  au!
  au BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   execute 'normal! g`"zvzz' |
    \ endif
augroup END

" -------------------- Key bindings -----------------------------------------
" Quiting failsefe
command! Wq :wq
command! WQ :wq

" Auto close bracet
inoremap " ""<Esc>i
inoremap ' ''<Esc>i
inoremap { {}<Esc>i
inoremap ( ()<Esc>i
inoremap [ []<Esc>i
