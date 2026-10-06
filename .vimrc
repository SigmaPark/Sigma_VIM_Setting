" ---- Encoding: read UTF-8 first, fall back to CP949 for legacy Korean files ----
" Do NOT set 'fileencoding' here: that would silently rewrite every saved file
" as UTF-8 and corrupt CP949 sources.
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,cp949,latin1

if has ("syntax")
	syntax on
endif

set ts=4 " Tab width
set shiftwidth=4 " Auto indentation tab width

set hlsearch " highlighting for searching pattern
set number " line number

"""========""========""========""========"=======#""========""========""========""========""=======#
"Vundle installation"

set nocompatible 	" be iMproved, required
filetype off 		" required
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
	Plugin 'VundleVim/Vundle.vim'
	Plugin 'scrooloose/nerdtree'
	Plugin 'yuttie/comfortable-motion.vim'
	Plugin 'vim-airline/vim-airline'
	Plugin 'neoclide/coc.nvim', {'pinned': 1}	" Vundle cannot pick a branch;
							" clone the release branch by hand (see README)
	Plugin 'bfrg/vim-cpp-modern' 
	Plugin 'tomasiser/vim-code-dark'
	Plugin 'airblade/vim-gitgutter'
call vundle#end()
filetype plugin indent on
"""========""========""========""======="=======#""========""========""========""========""=======#

"NerdTree key mapping
nnoremap <F3> :NERDTreeToggle<cr>
let g:NERDTreeWinSize = 60 " generous width for long variable/file names

"GUI font
if has('gui_running')
	set guifont=D2Coding\ 11
endif

"Vim-airline
" powerline_fonts needs a Powerline/Nerd-patched font; D2Coding provides one.
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
" airline feeds the buffer number to printf(). vim has no %n conversion, so
" '%n ' raises E767; airline's own default is '%s: '.
let g:airline#extensions#tabline#buffer_nr_format = '%s '

"Buffer navigation (cycle files in the focused split, splits stay put)
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [b :bprevious<CR>

"comfortable-motion
" friction is a constant deceleration, air_drag is velocity-proportional;
" raised both from the plugin defaults (80.0 / 2.0) to cut the low-speed
" drag tail short instead of gliding to a stop.
let g:comfortable_motion_friction = 140.0
let g:comfortable_motion_air_drag = 5.0

" coc.nvim 
set hidden
set updatetime=300
set shortmess+=c

" Tab completion
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Enter selection
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Go to error/warning
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Go to definitions
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Change name/symbol
nmap <leader>rn <Plug>(coc-rename)

"Vim-cpp-modern
let g:cpp_simple_highlight = 1
let g:cpp_named_requirements_highlight = 1

"vim-gitgutter
set signcolumn=yes " fixed gutter: signs coming and going would shift the text

" ---- Colors: Visual Studio 2017 Dark - C++ ----
" The VSCode theme in use on the PC (C/C++ Themes extension). codedark draws
" the editor chrome; the token colors below are copied from that theme's own
" file, cpptools_dark_vs.json, and the git gutter takes VSCode's dark defaults.
" Names only clangd can resolve (types, macros, parameters, members, ...)
" arrive as coc semantic tokens, which need "semanticTokens.enable": true in
" coc-settings.json.
if has('termguicolors') && $TERM_PROGRAM !=# 'Apple_Terminal'
	set termguicolors " Terminal.app lacks 24-bit color; codedark falls back to 256
endif

function! s:VsDarkColors() abort
	" coc gives every semantic highlight one priority, so where a modifier group
	" (CocSemTypeModClassDeduced on auto, say) overlaps its type group either one
	" may win. Only type groups get colors; auto shows the type it deduces.
	" Inactive preprocessor regions: VS and VSCode fade them to 55% opacity
	" instead of painting them as comments. A terminal cell has no alpha, so
	" #828282 is Normal's #D4D4D4 blended at 55% over the #1E1E1E background.
	" Two painters cover them: c.vim's cCppOut for a literal '#if 0' (set here
	" before the syntax file loads, so its 'hi def link cCppOut Comment' is
	" skipped), and clangd, which reports every inactive region - also ones
	" disabled through an undefined macro - as 'comment' semantic tokens that
	" coc paints over the syntax. Real comments get no token, so they stay green.
	let l:palette = {
		\ '#569CD6': ['Statement', 'Conditional', 'Repeat', 'Label', 'Keyword', 'Exception',
		\     'CocSemTypeKeyword', 'CocSemTypeModifier'],
		\ '#9B9B9B': ['PreProc', 'Include', 'Define', 'Macro', 'PreCondit'],
		\ '#C8C8C8': ['Identifier', 'Function', 'CocSemTypeNamespace', 'CocSemTypeVariable',
		\     'CocSemTypeFunction', 'CocSemTypeMethod', 'CocSemTypeLabel'],
		\ '#4EC9B0': ['CocSemTypeType', 'CocSemTypeClass', 'CocSemTypeStruct',
		\     'CocSemTypeEnum', 'CocSemTypeInterface', 'CocSemTypeTypeParameter',
		\     'CocSemTypeConcept'],
		\ '#BD63C5': ['CocSemTypeMacro'],
		\ '#7F7F7F': ['CocSemTypeParameter'],
		\ '#DADADA': ['CocSemTypeProperty'],
		\ '#B8D7A3': ['CocSemTypeEnumMember'],
		\ '#2B91AF': ['LineNr', 'CursorLineNr'],
		\ '#828282': ['cCppOut', 'CocSemTypeComment'],
		\ '#487E02': ['GitGutterAdd'],
		\ '#1B81A8': ['GitGutterChange', 'GitGutterChangeDelete'],
		\ '#F14C4C': ['GitGutterDelete'],
		\ }
	for [l:color, l:groups] in items(l:palette)
		for l:group in l:groups
			" coc and gitgutter define these as links; clear first so the color sticks.
			if l:group =~# '^\%(Coc\|GitGutter\)'
				execute 'highlight clear ' . l:group
			endif
			execute 'highlight ' . l:group . ' guifg=' . l:color
		endfor
	endfor
	" vim-cpp-modern paints std as a constant; VS draws namespaces plain.
	highlight link cppSTLnamespace Identifier
endfunction

augroup VsDarkColors
	autocmd!
	autocmd ColorScheme codedark call s:VsDarkColors()
augroup END

set background=dark
colorscheme codedark
let g:airline_theme = 'codedark'

" ---- Cursor shape per mode (DECSCUSR) ----
" Block in normal mode, bar in insert, underline in replace. Terminals that
" default to a bar cursor (Windows Terminal) would otherwise show a bar
" everywhere. Start in block and hand the bar back to the shell on exit.
if !has('gui_running')
	let &t_SI = "\e[6 q"
	let &t_SR = "\e[4 q"
	let &t_EI = "\e[2 q"
	let &t_ti .= "\e[2 q"
	let &t_te .= "\e[6 q"
endif

" ---- Session persistence ----
" `vim` with no file args restores the previous session; any other
" invocation (vim file.cpp, etc.) leaves the argument list alone. The
" session is refreshed on every exit so the next bare launch resumes here.
set sessionoptions-=options
" Keyed by cwd, so each project directory remembers its own session
" instead of every directory sharing one (path separators/colon can't
" live in a filename, so they are folded into '%').
let g:session_dir = expand('$HOME/.vim/sessions/')

function! s:SessionFile() abort
	return g:session_dir . substitute(getcwd(), '[\/:]', '%', 'g') . '.vim'
endfunction

function! s:RestoreSession() abort
	let l:file = s:SessionFile()
	if argc() == 0 && filereadable(l:file)
		execute 'source ' . fnameescape(l:file)
	endif
endfunction

function! s:SaveSession() abort
	call mkdir(g:session_dir, 'p')
	execute 'mksession! ' . fnameescape(s:SessionFile())
endfunction

augroup AutoSession
	autocmd!
	autocmd VimEnter * nested call s:RestoreSession()
	autocmd VimLeave * call s:SaveSession()
augroup END