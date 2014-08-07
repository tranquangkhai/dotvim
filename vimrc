" An example for a vimrc file.
"
" Maintainer: Tran Quang Khai <tranquangkhai.vn@gmail.com>
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc
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
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
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

  set autoindent		" always set autoindenting on

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
set cinoptions=(0,u0,U0
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
	set t_ts=k
	set t_fs=\
	set titlestring=%t
	set title
endif

" }}}
" folding {{{

" default folding
set foldmethod=marker 
set foldmarker={{{,}}}
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

""set statusline=%t[%{strlen(&fenc)?&fenc:'none'},%{&ff}]%h%m%r%y%=%c,%l/%L\ %P
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
"	import ibus
"	bus = ibus.Bus()
"	ic = ibus.InputContext(bus, bus.current_input_contxt())
"	ic.disable()
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
autocmd FileType python setl textwidth=80
autocmd FileType python set omnifunc=jedi#completions
let python_highlight_all = 1
nnoremap gpy :!/usr/local/bin/ctags -R --python-kinds=-i *.py<CR>

"}}}
" Ruby {{{
autocmd FileType ruby setl autoindent
autocmd FileType ruby setl expandtab
autocmd FileType ruby setl tabstop=2 shiftwidth=2 softtabstop=2
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
filetype plugin on
filetype plugin indent off
" {{{ neobundle
"execute :NeoBundleInstall
if has('vim_starting')
	set rtp+=~/.vim/bundle/neobundle.vim/
	call neobundle#rc(expand('~/.vim/bundle'))
endif


NeoBundleFetch "Shougo/neobundle.vim"
"}}}
" {{{ neocomplcache

NeoBundle "Shougo/neocomplcache"
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_smart_case = 1
"}}}
" {{{ neosnippets

NeoBundle 'Shougo/neosnippet'

" }}}
" {{{ vimproc

NeoBundle 'Shougo/vimproc', { 'build' : { 
		\ 'cygwin' : 'make -f make_cygwin.mak', 
		\ 'mac' : 'make -f make_mac.mak', 
		\ 'unix' : 'make -f make_unix.mak', 
		\ }, 
		\ }

"}}}
" vimfiler{{{

NeoBundle "Shougo/vimfiler"
""let g:vimfiler_as_default_explorer=1

"}}}
" unite.vim{{{

NeoBundle "Shougo/neomru.vim"

NeoBundle "Shougo/unite.vim"

" <ESC> to leave Unite mode
autocmd vimrc FileType unite nmap <buffer> <ESC> <Plug>(unite_exit)
autocmd vimrc FileType unite imap <buffer> jj <Plug>(unite_insert_leave)

" Unite action mapping
autocmd vimrc FileType unite nnoremap <buffer><expr> sp unite#do_action('split')
autocmd vimrc FileType unite nnoremap <buffer><expr> vsp unite#do_action('vsplit')
autocmd vimrc FileType unite nnoremap <buffer><expr> tab unite#do_action('tabopen')

" NOTE: overriding the mapping for 'gb', which was :ls :buf
nnoremap gb :UniteWithBufferDir -buffer-name=files buffer file_mru file<CR>
nnoremap gc :UniteWithCurrentDir -buffer-name=files buffer file_mru file<CR>
nnoremap gl :Unite -buffer-name=files buffer file_mru file<CR>

" resume
nnoremap gn :UniteResume<CR>

" config
let g:unite_source_file_mru_limit = 200
let g:unite_kind_openable_cd_command = 'CD'
let g:unite_kind_openable_lcd_command = 'LCD'
let g:unite_source_file_mru_filename_format = ''
let g:unite_enable_start_insert = 1

" grep search
nnoremap <silent> ge :<C-u>Unite grep:. -buffer-name=search-buffer<CR>

" grep search under cursor
nnoremap <silent> gu :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>

" re-grep
nnoremap <silent> gr :<C-u>UniteResume search-buffer<CR>

"}}}
" unite-outline{{{

NeoBundle 'h1mesuke/unite-outline'

" outline
nnoremap go :Unite -auto-preview outline<CR>

"}}}
" unite-colorscheme{{{

NeoBundle 'ujihisa/unite-colorscheme'

"}}}
" vim-colorscheme{{{

NeoBundle 'flazz/vim-colorschemes'
set t_Co=256
set background=dark
" solarized options
let g:solarized_termcolors = 256
let g:solarized_bold = 0
let g:solarized_underline = 0
colorscheme solarized
"}}}
"unite-font{{{
NeoBundle "ujihisa/unite-font"
"}}}
" {{{ vimshell

NeoBundle 'Shougo/vimshell'
augroup vimrc-vimshell
	au!

	" Ctrl-D to exit
	au FileType {vimshell,int-*} imap <buffer><silent> <C-d> <ESC>:q<CR>

	" Disable cursor keys
	au FileType {vimshell,int-*} imap <buffer><silent> OA <Nop>
	au FileType {vimshell,int-*} imap <buffer><silent> OB <Nop>
	" au FileType {vimshell,int-*} imap <buffer><silent> OC <Nop>
	" au FileType {vimshell,int-*} imap <buffer><silent> OD <Nop>

	" Switch to insert mode on BufEnter
	au BufEnter *vimshell* call vimshell#start_insert()
	au BufEnter iexe-*,texe-* startinsert!
augroup END

" Interactive
function! s:open_vimshellinteractive()
	let default = ''
	if has_key(g:vimshell_interactive_interpreter_commands, &filetype)
		let default = g:vimshell_interactive_interpreter_commands[&filetype]
	endif
	let interp = input("Interpreter: ", default)
	execute 'VimShellInteractive' interp
endfunction
nnoremap <silent> gsi :call <sid>open_vimshellinteractive()<CR>

" Terminal
function! s:open_vimshellterminal()
	let shell = input("Interpreter: ")
	execute 'VimShellTerminal' shell
endfunction
nnoremap <silent> gst :call <sid>open_vimshellterminal()<CR>

" Shell
nnoremap <silent> gsh :VimShellPop <C-R>=expand('%:h:p')<CR><CR>
au vimrc-vimshell FileType vimshell call vimshell#altercmd#define('sl', 'ls')
au vimrc-vimshell FileType vimshell call vimshell#altercmd#define('ll', 'ls -l')

" Python
nnoremap <silent> gspy :VimShellTerminal ipython -colors NoColor<CR>
hi termipythonPrompt ctermfg=40
hi termipythonOutput ctermfg=9

"}}}
" {{{tagbar

NeoBundle 'majutsushi/tagbar'
if has("mac")
	let g:tagbar_ctags_bin='/usr/local/bin/ctags'
elseif has("unix")
	let g:tagbar_ctags_bin='/usr/bin/ctags'
endif
let g:tagbar_width=26
nnoremap gtb :TagbarToggle<CR>

"}}}
" {{{sudo-gui

NeoBundle "gmarik/sudo-gui.vim"

"}}}
"{{{ airline
"https://powerline.readthedocs.org/en/latest/installation/linux.html#font-installation
NeoBundle 'bling/vim-airline'
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme='powerlineish'
"}}}
" powertabline {{{
NeoBundle 'alpaca-tc/alpaca_powertabline'
"}}}
"{{{ python
NeoBundle "python.vim"
NeoBundle "nvie/vim-flake8"
NeoBundle "davidhalter/jedi-vim"
"}}}
" {{{ matchit
NeoBundle 'matchit.zip'
" }}}
" vim-autoclose{{{

NeoBundle 'yuroyoro/vim-autoclose'

"}}}
" surround{{{

NeoBundle 'surround.vim'

"}}}
NeoBundle 'YankRing.vim'
" vim-template{{{

NeoBundle 'thinca/vim-template'

"}}}
" vim-latex {{{
NeoBundle "jcf/vim-latex"
let g:tex_flavor = 'latex'
au BufNewFile,BufRead *.tex,*.latex,*.sty,*.dtx,*.ltx,*.bbl setf tex
set shellslash
set grepprg=grep\ -nH\ $*'
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_CompileRule_dvi = 'platex --interaction=nonstopmode $*'
let g:Tex_FormatDependency_pdf = 'dvi,pdf'
let g:Tex_CompileRule_pdf = 'dvipdfmx $*.dvi'
if has("mac")
	let g:Tex_BibtextFlavor = 'pbibtex'
	let g:Tex_ViewRule_pdf = 'Preview.app'
elseif has("unix")
	let g:Tex_BibtextFlavor = 'pbibtex'
	let g:Tex_ViewRule_pdf = 'gnome-open'
endif
"}}}
" vim-ruby {{{
NeoBundle "vim-ruby/vim-ruby"
compiler ruby
"}}}
" vim-rails {{{
NeoBundle "tpope/vim-rails"
"}}}
" comments{{{
NeoBundle "comments.vim"
"}}}
" Ctrlp{{{
NeoBundle "kien/ctrlp.vim"
"}}}
" vim-fugitive {{{
NeoBundle "tpope/vim-fugitive"
"}}}
filetype indent on
filetype plugin indent on
