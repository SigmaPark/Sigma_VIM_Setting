
if has ("syntax")
	syntax on
endif

colorscheme desert

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
	Plugin 'neoclide/coc.nvim', {'branch': 'release'}
	Plugin 'bfrg/vim-cpp-modern' 
call vundle#end()
filetype plugin indent on
"""========""========""========""======="=======#""========""========""========""========""=======#

"NerdTree key mapping
nmap nerd :NERDTreeToggle<cr>

"Vim-airline
let g:airline_powerline_font = 1
let g:airline#extensions#tabline#enable = 1
let g:airline#extentions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#buffer_nr_format = '%n '

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