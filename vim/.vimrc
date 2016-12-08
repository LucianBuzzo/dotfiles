set runtimepath+=~/.dotfiles/vim
execute pathogen#infect('bundle/{}', '~/.dotfiles/vim/bundle/{}')
syntax on
filetype plugin indent on

set autochdir

"Set title so that dc-autoswap plugin works
set title titlestring=

"Disable visual bell - fixes OOB scroll freeze
set noeb vb t_vb=

"Removes vi compatibility
set nocompatible
set modelines=0

"BACKUP SETTINGS
"set nobackup
"set nowritebackup
set backupcopy=yes
set backupdir=~/.vimbackups/.backup//
set directory=~/.vimbackups/.swp//
set undodir=~/.vimbackups/.undo//

" REMOVE WHITESPACE ON SAVE
":autocmd BufWritePost * :StripWhitespace
let blacklist = ['md', 'markdown', 'mdown']
:autocmd BufWritePost * if index(blacklist, &ft) < 0 | :StripWhitespace

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
set undofile
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
set guifont=Sauce\ Code\ Powerline:h14

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
nnoremap <leader>1 :set background=light<cr>
nnoremap <leader>2 :set background=dark<cr>
nnoremap <leader>co ggj<S-v>G:w<space>!pbcopy<CR><CR>
nnoremap <leader>ps [{j<S-v>]}k:CSScomb<esc>
"Folding
nnoremap <leader>f za
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
nnoremap <leader>a= :Tabularize /=<CR>
vnoremap <leader>a= :Tabularize /=<CR>
nnoremap <leader>a: :Tabularize /:\zs<CR>
vnoremap <leader>a: :Tabularize /:\zs<CR>
nnoremap <leader>def :call DrupalExportField()<CR>
nnoremap <leader>dcc :call DrupalDrushCCall()<CR>

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
vnoremap : :B<space>

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
"set listchars=tab:▸\ ,eol:¬

"Windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Esc
inoremap § <Esc>
vnoremap § <Esc>
nnoremap § <Esc>

"SQUIGGLE LANG
au BufRead,BufNewFile *.sqg set filetype=javascript

"NODE TEMPLATING
au BufRead,BufNewFile *.ect set filetype=html

"FORTRAN
"au BufRead,BufNewFile *.f95 set filetype=html

"DRUPAL CONFIG
au BufRead,BufNewFile *.drush set filetype=php
au BufRead,BufNewFile *.module set filetype=php
au BufRead,BufNewFile *.inc set filetype=php
au BufRead,BufNewFile *.install set filetype=php
au BufRead,BufNewFile *.rule set filetype=php
au BufRead,BufNewFile *.test set filetype=php

au BufRead,BufNewFile *.theme set filetype=php

"MARKDOWN
autocmd BufRead,BufNewFile *.md       setlocal spell spelllang=en_gb
autocmd BufRead,BufNewFile *.markdown setlocal spell spelllang=en_gb
autocmd BufRead,BufNewFile *.mdown    setlocal spell spelllang=en_gb

"SYNTAX HIGHLIGHTING
"au FileType javascript call JavaScriptFold()

"JAVASCRIPT CONFIG
"au BufRead,BufNewFile *.ect set filetype=html

"SOLARIZED CONFIG
"let g:solarized_termcolors=256
let g:solarized_visibility = "high"
let g:solarized_contrast = "high"
let g:solarized_termcolors=16
set background=light
colorscheme solarized

"PENCIL THEME
let g:pencil_terminal_italics = 1
"set background=dark
"colorscheme pencil

"AIRLINE CONFIG
set laststatus=2
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='solarized'
"let g:airline_theme = 'pencil'

"NERDTREE CONFIG
map <C-n> :NERDTreeToggle<CR>

"EMMET CONFIG

"VIM MAGIC
augroup reload_vimrc " {
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC | AirlineRefresh
    autocmd BufWritePost $MYVIMRC AirlineRefresh
augroup END " }

"MAC Keybinds
vmap <C-c> :w !pbcopy<CR><CR>


"CODE COMBAT
augroup codecombat_setup " {
  au BufRead,BufNewFile *.ccjs set filetype=javascript
  au FileType javascript setlocal dictionary+=~/.dotfiles/codecombat/lib/**
  au BufRead,BufNewFile *.ccjs argadd ~/.dotfiles/codecombat/lib/ccFunctions.ccjs


augroup END " }


"AUTOCOMPLETE
let g:SuperTabDefaultCompletionType = "<c-n>"

"SYNTASTIC

nnoremap <leader>st :SyntasticToggleMode<CR>

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_enable_balloons = 1
let g:syntastic_enable_signs = 1
let g:CSSLint_FileTypeList = ['css', 'less', 'sess']
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_php_checkers = ['php', 'phpmd']
let g:syntastic_php_phpmd_post_args = '~/phpmd-ruleset.xml'
let g:syntastic_css_csslint_args="--ignore=unique-headings,qualified-headings,adjoining-classes,universal-selector,floats,important,box-model"
"let g:syntastic_stl_format = '[%E{Err: %fe #%e}%B{, }%W{Warn: %fw #%w}]'
let syntastic_mode_map = { 'passive_filetypes': ['html'] }
let g:syntastic_ignore_files = ['.sqg$']

highlight SyntasticErrorLine guibg=#eee8d6
highlight SyntasticWarningLine guibg=#eee8d6
highlight SyntasticWarning guibg=#c94c22 guifg=#fdf6e4
highlight SyntasticError guibg=#c94c22 guifg=#fdf6e4

highlight link SyntasticError SpellBad
highlight link SyntasticWarning SpellCap


"SYNTASTIC SASS
let g:syntastic_scss_checkers = ['scss_lint']

"FUNCTIONS FOR ABBREVIATING COMMANDS
fu! Single_quote(str)
    return "'" . substitute(copy(a:str), "'", "''", 'g') . "'"
endfu

fu! Cabbrev(key, value)
    exe printf('cabbrev <expr> %s (getcmdtype() == ":" && getcmdpos() <= %d) ? %s : %s',
        \ a:key, 1+len(a:key), Single_quote(a:value), Single_quote(a:key))
endfu

"ALIAS CSScomb command to Psort
cabbrev Psort CSScomb


"CTRL P setup
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

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


" JSDOC
au BufRead,BufNewFile *.js     inoremap <buffer> <C-d> :JsDoc<CR>

"PHP DOC
au BufRead,BufNewFile *.php     inoremap <buffer> <C-d> :call PhpDoc()<CR>
au BufRead,BufNewFile *.php     nnoremap <buffer> <C-d> :call PhpDoc()<CR>
au BufRead,BufNewFile *.php     vnoremap <buffer> <C-d> :call PhpDocRange()<CR>
au BufRead,BufNewFile *.inc     inoremap <buffer> <C-d> :call PhpDoc()<CR>
au BufRead,BufNewFile *.inc     nnoremap <buffer> <C-d> :call PhpDoc()<CR>
au BufRead,BufNewFile *.inc     vnoremap <buffer> <C-d> :call PhpDocRange()<CR>
au BufRead,BufNewFile *.module  inoremap <buffer> <C-d> :call PhpDoc()<CR>
au BufRead,BufNewFile *.module  nnoremap <buffer> <C-d> :call PhpDoc()<CR>
au BufRead,BufNewFile *.module  vnoremap <buffer> <C-d> :call PhpDocRange()<CR>
au BufRead,BufNewFile *.install inoremap <buffer> <C-d> :call PhpDoc()<CR>
au BufRead,BufNewFile *.install nnoremap <buffer> <C-d> :call PhpDoc()<CR>
au BufRead,BufNewFile *.install vnoremap <buffer> <C-d> :call PhpDocRange()<CR>








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
" Vim global plugin for highlighting matches
" Last change:  Thu Dec 19 16:08:21 EST 2013
" Maintainer: Damian Conway
" License:  This file is placed in the public domain.

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

"=====[ ShellAsync ]=====
let g:shellasync_terminal_insert_on_enter  = 0
let g:shellasync_print_return_value  = 1

"=====[ Slack integration ]=====

nnoremap <leader>* <S-v>y:call P('<C-R><C-R>" <C-R><C-R>=expand("%:e")<CR>')<CR> <S-v>d
inoremap <C-d> <ESC><S-v>y:call P('<C-R><C-R>" <C-R><C-R>=expand("%:e")<CR>')<CR> <S-v>di
nnoremap <C-d> <S-v>y:call P('<C-R><C-R>" <C-R><C-R>=expand("%:e")<CR>')<CR> <S-v>d
nnoremap <leader>@ :call P('')<left><left>

function! VtoP()
  let line = getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]]
  echom line
endfunction

function! P(words)
  let message = ':vim: ' . a:words
  let token = 'xoxp-3937044139-4636353582-4755857638-30ece2'
  let channel = 'C03TK1A61'
  let text = substitute(message, ' ', '%20', 'g')
  let resp = system('curl "https://slack.com/api/chat.postMessage?token=' . token . '&channel=' . channel . '&as_user=true&text=' . text . '"')
  let success = matchstr(resp, '"ok":true')
  if empty(success)
    echom 'Message sending failed'
  else
    echom 'Message sent'
  endif
endfunction

nnoremap <leader>M :vnew<CR>:setlocal filetype=scratch<CR>:split ~/.dotfiles/slackServer/message.log<CR>:setlocal autoread<CR>:setlocal updatetime=100<CR>:au CursorHold * checktime<CR><C-w>j:call SlackMap()<CR>

function! SlowUpdate()
  sleep 500m
  checktime
endfunction

function! SlackMessenger()
  silent! echom system('node ~/.dotfiles/slackServer/server.js')
endfunction


function! SlackMap()
  silent! echom system('forever stop ~/.dotfiles/slackServer/server.js');
  silent! echom system('forever start ~/.dotfiles/slackServer/server.js');
  autocmd VimLeave * !forever stop ~/.dotfiles/slackServer/server.js
  inoremap <buffer> <CR> <ESC><S-v>y:call P('<C-R><C-R>" <C-R><C-R>=expand("%:e")<CR>')<CR><S-v>d:call SlowUpdate()<CR><C-w>kG<C-w>ji
  nnoremap <buffer> <CR> <ESC><S-v>y:call P('<C-R><C-R>" <C-R><C-R>=expand("%:e")<CR>')<CR><S-v>d:call SlowUpdate()<CR><C-w>kG<C-w>j
endfunction

"=====[ instant markdown ]=====
let g:instant_markdown_slow = 0
