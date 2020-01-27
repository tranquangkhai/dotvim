" An example for a vimrc file.
"
" Maintainer: Tran Quang Khai <tranquangkhai.vn@gmail.com>
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"    for OpenVMS:  sys$login:.vimrc
" default {{{
" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup" do not keep a backup file, use versions instead
else
  set backup" keep a backup file
endif

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent" always set autoindenting on

endif " has("autocmd")
"}}}

" Settings: -----------------------------
" {{{ reset augroup vimrc
augroup vimrc
autocmd!
augroup END
"}}}
" {{{ .vimrc editing and reloading

" automatic reloading
if has("autocmd")
  autocmd vimrc BufWritePost .vimrc,~/.vim/vimrc,~/.vim/vimrc.local
  \  source $MYVIMRC
  \| if has('gui_running')
  \|     source $MYGVIMRC
  \| endif
endif

function! s:open_vimrc(command, vimrc)
  if empty(bufname("%")) && ! &modified && empty(&buftype)
    execute 'edit' a:vimrc
  else
    execute a:command a:vimrc
  endif
endfunction
nnoremap <silent> <leader>v :call <sid>open_vimrc('vsplit', $MYVIMRC)<CR>
nnoremap <silent> <C-w><leader>v :call <sid>open_vimrc('tabnew', $MYVIMRC)<CR>

" }}}
" {{{ encoding and format

set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,euc-jp,sjis,iso-2022-jp,cp932

set fileformat=unix
set fileformats=unix,dos,mac

" }}}
" {{{ indenting

" these below are the defaults. maybe overridden later
set tabstop=4
set shiftwidth=4
set noexpandtab
"set autoindent
set copyindent
set cindent

" define indentation around parentheses.
set cinoptions=(0,u0,U0,w1,Ws
" do not indent before C++ scope declarations: public; protected; private;
set cinoptions+=g0
" do not indent function return type
set cinoptions+=t0
" do not indent inside namespace
set cinoptions+=N-s

" }}}
" {{{ terminal titles

" for 'screen'
if $STY != ''
  set t_ts=?k
  set t_fs=?\
  set titlestring=%t
  set title
endif

" }}}
" folding {{{

" default folding
set foldmethod=marker
" set foldmethod=expr
" 	\ foldexpr=lsp#ui#vim#folding#foldexpr()
" 	\ foldtext=lsp#ui#vim#folding#foldtext()
set foldmarker={{{,}}}

" latex folding

"}}}
"{{{ status line
" show incomplete commands
set showcmd

" list candidates in statusline for commandline completion
set wildmenu
set wildmode=longest,list
set wildignore=*~

" hide mode in command line
set noshowmode

" always show statusline
set laststatus=2

set statusline=%t[%{strlen(&fenc)?&fenc:'none'},%{&ff}]%h%m%r%y%=%c,%l/%L\ %P
"}}}
" {{{ search

set incsearch   " do incremental searching
set smartcase   " but don't ignore it, when search string contains uppercase letters
set ignorecase  " ignore case
set showmatch   " showmatch: Show the matching bracket for the last ')'?
set wrapscan    " search wrap around the end of the file
set report=0    " report always the number of lines changed
set matchpairs+=<:>

" }}}
"{{{ key mappings
" list and open buffer
nnoremap gb :ls<CR>:buf<Space>

" make <c-l> clear the highlight as well as redraw
nnoremap <silent> <C-L> :nohls<CR><C-L>

" reselect visual block after indent/unindent
vnoremap < <gv
vnoremap > >gv

" natural movement for wrapped lines
noremap j gj
noremap gj j
noremap k gk
noremap gk k

" toggle wrap
nnoremap <silent> mw :set wrap!<CR>

" toggle list
nnoremap <silent> ml :set list!<CR>

" disable command-line window
nnoremap q: :q
"}}}
" {{{ wincmd

let s:wincmd_keys = ['h', 'j', 'k', 'l', 'w', 'p']
let s:wincmd_keys_keep_insert = ['H', 'J', 'K', 'L', '=', '>', '<', '+', '-']

" <C-w> in insert mode.
function! s:define_wincmds()
  for cmd in s:wincmd_keys
    execute 'inoremap <silent>' '<C-w>'.cmd '<ESC>:wincmd '.cmd.'<CR>'
  endfor
  for cmd in s:wincmd_keys_keep_insert
    execute 'inoremap <silent>' '<C-w>'.cmd '<C-o>:wincmd '.cmd.'<CR>'
  endfor
endfunction
call s:define_wincmds()

" wincmd mode
function! s:echomode(...)
  if ! &showmode
    return
  endif

  let mode = ''
  if a:0 > 0
    let mode = '-- '.a:000[0].' --'
  endif
  
  echohl ModeMsg | echo mode | echohl None
  redraw
endfunction

function! s:wincmdmode()
  while 1
    call s:echomode('RESIZE')
    let key = nr2char(getchar())
    if index(s:wincmd_keys, key) < 0 &&
    \ index(s:wincmd_keys_keep_insert, key) < 0
      break
    endif
    execute 'wincmd' key
    redraw
  endwhile
  call s:echomode()
endfunction

let s:wincmd_mode_trigger_keys = ['>', '<', '+', '-']
function! s:define_wincmd_mode_triggers()
  for cmd in s:wincmd_mode_trigger_keys
    execute 'nnoremap <silent>' '<C-w>'.cmd '<C-w>'.cmd.':call <sid>wincmdmode()<CR>'
  endfor
endfunction
call s:define_wincmd_mode_triggers()

" reset window size on VimResized
function! s:on_resized()
  let tab = tabpagenr()
  tabdo wincmd =
  execute 'normal!' tab.'gt'
endfunction
au vimrc VimResized * call <sid>on_resized()

" }}}
"{{{ Persistent undo
set undodir=~/.vim/undodir
set undofile
set undolevels=1000 "maximum number of changes that can be undone
set undoreload=10000 "maximum number lines to save for undo on buffer reload
"}}}
"{{{ grep with quickfix
au QuickFixCmdPost *grep* copen
"}}}
"{{{ error with quickfix
au QuickFixCmdPost [^l]* nested cwindow
au QuickFixCmdPost    l* nested lwindow
"}}}
"{{{ get running os
function! GetRunningOS()
  if has("unix")
    if system('uname')=~'Darwin'
      return 'mac'
    else
      return 'linux'
    endif
  endif
endfunction
let os=GetRunningOS()
"}}}
"{{{ spell
set spelllang+=cjk
set spell
"}}}
" {{{ miscellaneous

" do not wrap text by default.
set nowrap

" when wrap is on...
let &showbreak = '> '
set linebreak
set breakat&

" show line number
set number

" suppress error bells
set noerrorbells
set novisualbell

" lines before and after the current line when scrolling
set scrolloff=2

" show tab as >---
set listchars+=tab:>-

" split direction
set splitbelow
set splitright

" completion
set completeopt=menuone

" keep history
set history=500

" virtualedit in block mode
set virtualedit=block

" try to keep current column
set nostartofline

"function! s:ibusdisable()
"python << EOF
"try:
"import ibus
"bus = ibus.Bus()
"ic = ibus.InputContext(bus, bus.current_input_contxt())
"ic.disable()
"except: pass
"EOF
"endfunction
"autocmd vimrc InsertLeave * call <sid>ibusdisable()

" Working with split screen nicely
" Resize Split When the window is resized"
au VimResized * :wincmd =


" }}}

" FileType: ---------------------
" Python {{{

autocmd FileType python setl autoindent
autocmd FileType python setl nosmartindent
autocmd FileType python setl smarttab
autocmd FileType python setl cindent
autocmd FileType python setl expandtab tabstop=4 shiftwidth=4 softtabstop=4
autocmd FileType python setl textwidth=79
let python_highlight_all = 1
"}}}
" Ruby {{{
autocmd FileType ruby setl autoindent
autocmd FileType ruby setl expandtab
autocmd FileType ruby setl tabstop=2 shiftwidth=2 softtabstop=2
"}}}
"{{{ Tex
autocmd FileType tex setlocal foldmethod=syntax
let g:tex_fold_enabled=1
let g:tex_fold_automatic=1
let g:tex_fold_envs=0
let g:tex_flavor = 'latex'
"}}}

" Commands: ---------------------
" {{{ :DiffOrig

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
  \ | wincmd p | diffthis
endif

" }}}

" Plugins: ----------------------
"{{{ python with virtualenv support
python3 << EOF
import os
virtualenv = os.environ.get('VIRTUAL_ENV')
if virtualenv:
  activate_this = os.path.join(virtualenv, 'bin', 'activate_this.py')
  if os.path.exists(activate_this):
    exec(open(activate_this).read(), dict(__file__=activate_this))
EOF
"}}}
"{{{ color setting
syntax enable
set background=light
let g:solarized_termcolors=256
colorscheme solarized
" colorscheme zenburn
"}}}
"{{{ airline: options
let g:airline_solarized_bg='dark'
"}}}
"{{{ vimtex: options
" Ref:
" https://wikimatze.de/vimtex-the-perfect-tool-for-working-with-tex-and-vim/
" http://applepine1125.hatenablog.jp/entry/2017/11/13/021152
" https://texwiki.texjp.org/?Latexmk
let g:vimtex_view_method = 'zathura'
let g:vimtex_compiler_latexmk = {
    \ 'background' : 1,
    \ 'build_dir' : '',
    \ 'callback' : 1,
    \ 'continuous' : 1,
    \ 'executable' : 'latexmk',
    \ 'options' : [
    \   '-pdfdvi',
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
    \ ],
    \}
"}}}
"{{{ matchit.vim (default)
runtime macros/matchit.vim
"}}}
"{{{ slime-vim
let g:slime_target = "vimterminal"
"}}}
"{{{ leetcode.vim
let g:leetcode_browser = 'firefox'
let g:leetcode_solution_filetype = 'python3'
"}}}
"{{{ neosnippet.vim
" Plugin key-mappings.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
"imap <expr><TAB>
" \ pumvisible() ? "\<C-n>" :
" \ neosnippet#expandable_or_jumpable() ?
" \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For conceal markers.
if has('conceal')
  set conceallevel=2 concealcursor=niv
  endif
"}}}
"{{{ asynccomplete.vim
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<cr>"
"}}}
" vim-lsp{{{
function! s:configure_lsp() abort
	setlocal omnifunc=lsp#complete 

	nnoremap <buffer> <C-]> :<C-u>LspDefinition<CR>
	nnoremap <buffer> gd :<C-u>LspDefinition<CR>
	nnoremap <buffer> gD :<C-u>LspReferences<CR>
	nnoremap <buffer> gs :<C-u>LspDocumentSymbol<CR>
	nnoremap <buffer> gS :<C-u>LspWorkspaceSymbol<CR>
	nnoremap <buffer> gQ :<C-u>LspDocumentFormat<CR>
	vnoremap <buffer> gQ :LspDocumentRangeFormat<CR>
	nnoremap <buffer> K :<C-u>LspHover<CR>
	nnoremap <buffer> <F1> :<C-u>LspImplementation<CR>
	nnoremap <buffer> <F2> :<C-u>LspRename<CR>
endfunction
"}}}
" vimteractive{{{
let g:vimteractive_default_shells = {'python': 'ipython'}
let g:vimteractive_vertical = 1
let g:vimteractive_bracketed_paste_default = 0
"}}}
"{{{ NERDTree
au VimEnter * NERDTree
"}}}

packloadall
silent! helptags ALL
