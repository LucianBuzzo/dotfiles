" To disable a plugin, add it's bundle name to the following list
let g:pathogen_disabled = []

set runtimepath+=~/.dotfiles/vim
execute pathogen#infect('bundle/{}', '~/.dotfiles/vim/bundle/{}')
syntax on
filetype plugin indent on

"Automatically change directory to current file Borks <C-p> though :(
"set autochdir

"Set title so that dc-autoswap plugin works
set title titlestring=

"Disable visual bell - fixes OOB scroll freeze
set noeb vb t_vb=

"Removes vi compatibility
set nocompatible
set modelines=0

" Neomake setup
autocmd! BufWritePost,BufWinEnter * Neomake
"let g:neomake_open_list = 2

" Mouse support
set mouse=a

"BACKUP SETTINGS
set nobackup
set nowritebackup
set noswapfile
set noundofile

"SAVE
inoremap <c-s> <ESC>:w<CR>
nnoremap <c-s> <ESC>:w<CR>

"GENERAL
set t_Co=256
let javaScript_fold=1
highlight Folded ctermfg=Blue
set wrap
set textwidth=80
set formatoptions=qrn1
let &colorcolumn=join(range(81,81),",")
set ruler
set number
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent
set foldmethod=indent
set foldlevelstart=99
set laststatus=2
set ttimeoutlen=50
set pastetoggle=<F10>
set showcmd
set showmode
set encoding=utf-8
set hidden
set wildmenu
set wildmode=list:longest
set visualbell
set cursorline
"set ttyfast
set backspace=indent,eol,start
set relativenumber
" When the page starts to scroll, keep the cursor 8 lines from the top and 8
" lines from the bottom
set scrolloff=8
"limit syntax highlighting to 160 columns
set synmaxcol=320

"=====[ GUI OPTIONS ]=====
"Hides scrollbars
set guioptions-=r
set guioptions-=l
set guioptions-=R
set guioptions-=L
"Font
"set guifont=droid\ sans\ mono\ for\ powerline:h12
set guifont=Ubuntu\ Mono\ 16

set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch

"=====[ Spell checking ]=====
nnoremap <leader>ce  :setlocal spell spelllang=en_gb<CR>
nnoremap <leader>cb  :setlocal spell spelllang=en-basic<CR>
hi SpellBad ctermfg=196

"=====[ Leader keybinds ]=====

let mapleader = " "
nnoremap <leader><space> :noh<cr>
nnoremap <leader>vh i"=====[<space><space>]=====<ESC>F[la
nnoremap <leader>w <C-w>v<C-w>l
nnoremap <silent> <Leader>= :exe "vertical resize " . (winwidth(0) * 5/4)<CR>
nnoremap <silent> <Leader>- :exe "vertical resize " . (winwidth(0) * 3/4)<CR>
nnoremap <silent> <Leader>v= :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> <Leader>v- :exe "resize " . (winheight(0) * 2/3)<CR>
nnoremap <leader>i =i{
nnoremap <leader>co ggj<S-v>G:w<space>!pbcopy<CR><CR>
nnoremap <leader>gs :Gstatus<CR>
"Folding
nnoremap <leader>f za
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

" Typos
command! -bang E e<bang>
command! -bang Q q<bang>
command! -bang W w<bang>
command! -bang QA qa<bang>
command! -bang Qa qa<bang>
command! -bang Wa wa<bang>
command! -bang WA wa<bang>
command! -bang Wq wq<bang>
command! -bang WQ wq<bang>


nnoremap <tab> %
vnoremap <tab> %
"vnoremap : :B<space>

nnoremap j gj
nnoremap k gk

inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

nnoremap ; :

"Save on losing focus
"
function! FocusLostWrite()
  execute '!normal wa'
endfunction
autocmd FocusLost * silent! wall

"set list
"set listchars=tab:▸\
"set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣
"hi NonText ctermfg=7 guifg=gray guibg=black
"hi SpecialKey guibg=none guifg=red

"Windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Esc
inoremap § <Esc>
vnoremap § <Esc>
nnoremap § <Esc>

"FORTRAN
"au BufRead,BufNewFile *.f95 set filetype=html

"MARKDOWN
autocmd BufRead,BufNewFile *.md       setlocal spell spelllang=en_gb
autocmd BufRead,BufNewFile *.markdown setlocal spell spelllang=en_gb
autocmd BufRead,BufNewFile *.mdown    setlocal spell spelllang=en_gb

"SVELTE CONFIG
au BufRead,BufNewFile *.svelte set filetype=html

"SYNTAX HIGHLIGHTING
"au FileType javascript call JavaScriptFold()

"JAVASCRIPT CONFIG
"au BufRead,BufNewFile *.ect set filetype=html

"Theme
"set t_Co=256
"@let g:solarized_visibility = "low"
"@let g:solarized_contrast = "high"
"@colorscheme solarized
"@set background=light

"NERDTREE CONFIG
"map <C-n> to open nerdtree file viewer
map <C-n> :NERDTreeToggle<CR>
"Show hidden files (files starting with a dot)
let NERDTreeShowHidden=1

"MAC Keybinds
vmap <C-c> :w !pbcopy<CR><CR>

"FUNCTIONS FOR ABBREVIATING COMMANDS
fu! Single_quote(str)
    return "'" . substitute(copy(a:str), "'", "''", 'g') . "'"
endfu

fu! Cabbrev(key, value)
    exe printf('cabbrev <expr> %s (getcmdtype() == ":" && getcmdpos() <= %d) ? %s : %s',
        \ a:key, 1+len(a:key), Single_quote(a:value), Single_quote(a:key))
endfu

"CTRL P setup
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'

"Fugitive
nmap <leader>gs :Gstatus<cr>
nmap <leader>gc :Gcommit<cr>
nmap <leader>ga :Gwrite<cr>
nmap <leader>gl :Glog<cr>
nmap <leader>gd :Gdiff<cr>

"EASYMOTION
let g:EasyMotion_do_mapping = 0 " Disable default mappings

" Bi-directional find motion
" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
nmap s <Plug>(easymotion-s)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
nmap s <Plug>(easymotion-s2)

" Turn on case insensitive feature
let g:EasyMotion_smartcase = 1


function! Wipeout()
  " list of *all* buffer numbers
  let l:buffers = range(1, bufnr('$'))

  " what tab page are we in?
  let l:currentTab = tabpagenr()
  try
    " go through all tab pages
    let l:tab = 0
    while l:tab < tabpagenr('$')
      let l:tab += 1

      " go through all windows
      let l:win = 0
      while l:win < winnr('$')
        let l:win += 1
        " whatever buffer is in this window in this tab, remove it from
        " l:buffers list
        let l:thisbuf = winbufnr(l:win)
        call remove(l:buffers, index(l:buffers, l:thisbuf))
      endwhile
    endwhile

    " if there are any buffers left, delete them
    if len(l:buffers)
      execute 'bwipeout' join(l:buffers)
    endif
  finally
    " go back to our original tab page
    execute 'tabnext' l:currentTab
  endtry
endfunction

nnoremap <leader>wo :call Wipeout()<CR>


"=============================================================

" Vim global plugin for highlighting matches
" Last change:  Thu Dec 19 16:08:21 EST 2013
" Maintainer: Damian Conway
" License:  This file is placed in the public domain.

"=============================================================

" If already loaded, we're done...
if exists("loaded_HLNext")
    finish
endif
let loaded_HLNext = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

"====[ INTERFACE ]=============================================

nnoremap           /   :call HLNextSetTrigger()<CR>/\v
nnoremap           ?   :call HLNextSetTrigger()<CR>?
nnoremap  <silent> n  n:call HLNext()<CR>
nnoremap  <silent> N  N:call HLNext()<CR>

" Default highlighting for next match...
highlight default HLNext ctermfg=white ctermbg=red


"====[ IMPLEMENTATION ]=======================================

" Are we already highlighting next matches???
let g:HLNext_matchnum = 0

" Clear previous highlighting and set up new highlighting...
function! HLNext ()
    " Remove the previous highlighting, if any...
    call HLNextOff()

    " Add the new highlighting...
    let target_pat = '\c\%#'.@/
    let g:HLNext_matchnum = matchadd('HLNext', target_pat)
endfunction

" Clear previous highlighting (if any)...
function! HLNextOff ()
    if (g:HLNext_matchnum > 0)
        call matchdelete(g:HLNext_matchnum)
        let g:HLNext_matchnum = 0
    endif
endfunction

" Prepare to active next-match highlighting after cursor moves...
function! HLNextSetTrigger ()
    augroup HLNext
        autocmd!
        autocmd  CursorMoved  *  silent! call HLNextMovedTrigger()
    augroup END
endfunction

" Highlight and then remove activation of next-match highlighting...
function! HLNextMovedTrigger ()
    augroup HLNext
        autocmd!
    augroup END
    call HLNext()
endfunction

" Source vimrc
nnoremap <Leader>sv :source $MYVIMRC<cr>

"====[ Syntastic ]============================================
" return full path with the trailing slash
"  or an empty string if we're not in an npm project
fun! s:GetNodeModulesAbsPath ()
  let lcd_saved = fnameescape(getcwd())
  silent! exec "lcd" expand('%:p:h')
  let path = finddir('node_modules', '.;')
  exec "lcd" lcd_saved

  " fnamemodify will return full path with trailing slash;
  " if no node_modules found, we're safe
  return path is '' ? '' : fnamemodify(path, ':p')
endfun

" return full path of local eslint executable
"  or an empty string if no executable found
fun! s:GetEslintExec (node_modules)
  let eslint_guess = a:node_modules is '' ? '' : a:node_modules . '.bin/eslint'
  return exepath(eslint_guess)
endfun

" if eslint_exec found successfully, set it for the current buffer
fun! s:LetEslintExec (eslint_exec)
  if a:eslint_exec isnot ''
    let b:syntastic_javascript_eslint_exec = a:eslint_exec
  endif
endfun

function! SetEslintExecutable ()
  let node_modules = s:GetNodeModulesAbsPath()
  let eslint_exec = s:GetEslintExec(node_modules)
  call s:LetEslintExec(eslint_exec)
endfunction

function! StrTrim(txt)
  return substitute(a:txt, '^\n*\s*\(.\{-}\)\n*\s*$', '\1', '')
endfunction

function! g:SetJSChecker()
    call SetEslintExecutable()

    for name in [ '.eslintrc', '.eslintrc.yml', '.eslintrc.json' ]
        let file = findfile(name, '.;')
        if len(file) > 0
            let b:syntastic_checkers = ['eslint']
            return
        endif
    endfor

    let b:syntastic_checkers = ['standard']
endfunction

let g:syntastic_ignore_files = ['.*\.html']

let g:syntastic_typescript_checkers = ['tslint']
let g:syntastic_javascript_checkers = [ 'eslint' ]
autocmd BufWritePost,BufWinEnter *.js call SetJSChecker()
autocmd BufWritePost,BufWinEnter *.jsx call SetJSChecker()
"autocmd FileType javascript let b:syntastic_checkers = findfile('.eslintrc.yml', '.;') != '' ? ['eslint'] : ['standard']

" Autofix javascript errors after writing
set autoread

" with eslint
let g:syntastic_javascript_eslint_args = ['--fix']

" with standard js
let g:syntastic_javascript_standard_args = ['--fix']

function! SyntasticCheckHook(errors)
  checktime
endfunction

