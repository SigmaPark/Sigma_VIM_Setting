" ---- Encoding: read UTF-8 first, fall back to CP949 for legacy Korean files ----
" Do NOT set 'fileencoding' here: that would silently rewrite every saved file
" as UTF-8 and corrupt CP949 sources.
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,cp949,latin1

" ---- Git Bash / MSYS on Windows ----
" Git for Windows ships /etc/vimrc, read before this file. It turns on the
" visual bell and clipboard=unnamed; undo both here (the later vimrc wins).
"   - the visual bell flashes the whole screen when the cursor hits an edge
"   - clipboard=unnamed makes x/dd/cw overwrite the system clipboard, so text
"     copied from another app dies the moment you delete a character.
"     Copy and paste explicitly with "+y / "+p instead.
set belloff=all
set clipboard=
" coc looks for coc-settings.json in ~/vimfiles on Windows. Keep it beside the
" plugins in ~/.vim so every machine uses the same path.
let g:coc_config_home = expand('$HOME/.vim')

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
set rtp+=$HOME/.vim/bundle/Vundle.vim
call vundle#begin('$HOME/.vim/bundle')
	Plugin 'VundleVim/Vundle.vim'
	Plugin 'scrooloose/nerdtree'
	Plugin 'yuttie/comfortable-motion.vim'
	Plugin 'vim-airline/vim-airline'
	Plugin 'neoclide/coc.nvim', {'pinned': 1}	" Vundle cannot pick a branch;
							" clone the release branch by hand (see README)
	Plugin 'bfrg/vim-cpp-modern' 
	Plugin 'morhetz/gruvbox'
call vundle#end()
filetype plugin indent on
"""========""========""========""======="=======#""========""========""========""========""=======#

"NerdTree key mapping
nnoremap <F3> :NERDTreeToggle<cr>
let g:NERDTreeWinSize = 47 " 1.5x the plugin default (31)

"Vim-airline
" powerline_fonts needs a Powerline/Nerd-patched font; set 1 after installing one.
let g:airline_powerline_fonts = 0
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

" Colorscheme
colorscheme gruvbox
set background=dark    " or light
"colorscheme desert

" ---- Session persistence ----
" `vim` with no file args restores the previous session; any other
" invocation (vim file.cpp, etc.) leaves the argument list alone. The
" session is refreshed on every exit so the next bare launch resumes here.
set sessionoptions-=options
let g:session_file = expand('$HOME/.vim/session.vim')

function! s:RestoreSession() abort
	if argc() == 0 && filereadable(g:session_file)
		execute 'source ' . fnameescape(g:session_file)
	endif
endfunction

function! s:SaveSession() abort
	execute 'mksession! ' . fnameescape(g:session_file)
endfunction

augroup AutoSession
	autocmd!
	autocmd VimEnter * nested call s:RestoreSession()
	autocmd VimLeave * call s:SaveSession()
augroup END