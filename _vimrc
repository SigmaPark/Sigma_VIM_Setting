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
	Plugin 'airblade/vim-gitgutter'
call vundle#end()
filetype plugin indent on
"""========""========""========""======="=======#""========""========""========""========""=======#

"NerdTree key mapping
nnoremap <F3> :NERDTreeToggle<cr>
let g:NERDTreeWinSize = 60 " generous width for long variable/file names

"GUI font
if has('gui_running')
	set guifont=D2Coding:h11
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

" ---- Build & run: CMake + Ninja + MSVC ----
" Start vim in the project root, the directory that holds CMakeLists.txt.
"   <F7>  :Build          configure build/ with Ninja when needed, then build
"   <F5>  :Run [args]     build, then run the executable target
"         :Run! [args]    pick the target again (asked when there are several)
"   ]q / [q               next / previous entry in the error list
let g:build_dir = 'build'

function! s:BuildError(message) abort
	echohl ErrorMsg
	echomsg a:message
	echohl None
endfunction

" Git Bash carries no MSVC environment (cl.exe, INCLUDE, LIB). The first build
" in a vim session copies whatever vcvars64.bat adds or changes into vim's own
" environment, so ninja and every compiler it starts inherit it. Diffing a
" snapshot taken before the call against one taken after it leaves alone the
" variables MSYS merely rewrote on the way into cmd.exe (HOME, TEMP, ...).
function! s:ImportMsvcEnv() abort
	if !empty($VCToolsInstallDir)
		return 1
	endif
	let l:vswhere = get(environ(), 'ProgramFiles(x86)', 'C:\Program Files (x86)')
		\ . '\Microsoft Visual Studio\Installer\vswhere.exe'
	let l:root = trim(system(shellescape(l:vswhere) . ' -latest -products "*"'
		\ . ' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64'
		\ . ' -property installationPath'))
	if v:shell_error || empty(l:root)
		call s:BuildError('no Visual Studio with the C++ toolset was found')
		return 0
	endif
	echo 'Loading the MSVC environment...'
	let l:bat = tempname() . '.bat'
	call writefile([
		\ '@set',
		\ '@echo ::vcvars::',
		\ '@call "' . l:root . '\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1',
		\ '@set'
		\ ], l:bat)
	let l:lines = systemlist('cmd //c '
		\ . shellescape(trim(system('cygpath -w ' . shellescape(l:bat)))))
	call delete(l:bat)
	let l:before = {}
	let l:after = {}
	let l:snapshot = l:before
	for l:line in l:lines
		let l:text = substitute(l:line, '\r$', '', '')
		if l:text ==# '::vcvars::'
			let l:snapshot = l:after
			continue
		endif
		let l:m = matchlist(l:text, '^\([^=]\+\)=\(.*\)$')
		if !empty(l:m)
			let l:snapshot[l:m[1]] = l:m[2]
		endif
	endfor
	if empty(get(l:after, 'VCToolsInstallDir', ''))
		call s:BuildError('vcvars64.bat did not set up the MSVC environment')
		return 0
	endif
	for [l:name, l:value] in items(l:after)
		if get(l:before, l:name, "\n") ==# l:value
			continue
		endif
		if l:name ==? 'PATH'
			let l:value = trim(system('cygpath -up ' . shellescape(l:value)))
		endif
		call setenv(l:name, l:value)
	endfor
	return 1
endfunction

" Configure once, the way VSCode's CMake Tools does: Ninja, Debug, and a
" compile_commands.json for clangd.
function! s:Configure() abort
	if filereadable(g:build_dir . '/build.ninja')
		return 1
	endif
	if filereadable(g:build_dir . '/CMakeCache.txt')
		call s:BuildError(g:build_dir
			\ . '/ was configured for another generator; remove it to switch to Ninja')
		return 0
	endif
	execute '!cmake -S . -B ' . shellescape(g:build_dir, 1)
		\ . ' -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON'
	if v:shell_error
		call s:BuildError('CMake configure failed')
		return 0
	endif
	return 1
endfunction

" MSVC and nvcc diagnostics, with or without a column:
"   G:\proj\foo.cpp(12): error C2065: ...    foo.cu(3,5): warning C4819: ...
let s:build_efm = join([
	\ '%f(%l\,%c): fatal %trror %*[A-Z]%n: %m',
	\ '%f(%l): fatal %trror %*[A-Z]%n: %m',
	\ '%f(%l\,%c): %t%*[a-z] %*[A-Z]%n: %m',
	\ '%f(%l): %t%*[a-z] %*[A-Z]%n: %m',
	\ '%f(%l\,%c): %tote: %m',
	\ '%f(%l): %tote: %m',
	\ '%f(%l): %t%*[a-z]: %m'
	\ ], ',')

function! s:Build() abort
	if !filereadable('CMakeLists.txt')
		call s:BuildError('no CMakeLists.txt here: start vim in the project root')
		return 0
	endif
	if !s:ImportMsvcEnv() || !s:Configure()
		return 0
	endif
	silent! wall
	let l:saved = [&makeprg, &errorformat, &makeencoding]
	" cmake --build drives the ninja recorded in CMakeCache.txt. Ninja 1.12
	" (bundled with Visual Studio) and 1.13 each delete the other's .ninja_log,
	" so building with whichever ninja comes first on PATH would force a full
	" rebuild every time VSCode and vim take turns on one build directory.
	let &makeprg = 'cmake --build ' . shellescape(g:build_dir)
	let &errorformat = s:build_efm
	" cl.exe writes its localized messages in the ANSI code page.
	let &makeencoding = 'cp949'
	try
		" The build log scrolls by on the terminal; redraw! then brings vim
		" back without a hit-enter prompt.
		silent make!
	finally
		let [&makeprg, &errorformat, &makeencoding] = l:saved
	endtry
	redraw!
	cwindow
	let l:failed = filter(getqflist(),
		\ {_, e -> e.text =~# '^ninja: \%(build stopped\|error\)'})
	if !empty(l:failed)
		call s:BuildError('Build failed')
		return 0
	endif
	echo 'Build succeeded'
	return 1
endfunction

" Executable targets as ninja lists them, relative to the build directory.
function! s:Executables() abort
	let l:exes = []
	for l:line in systemlist('ninja -C ' . shellescape(g:build_dir) . ' -t targets all')
		let l:target = matchstr(l:line, '^\S\+\ze: \S*EXECUTABLE_LINKER')
		if !empty(l:target)
			call add(l:exes, l:target)
		endif
	endfor
	return l:exes
endfunction

" The chosen target per project root, so <F5> asks only the first time.
let s:run_targets = {}

function! s:Run(pick, args) abort
	if !s:Build()
		return
	endif
	let l:exes = s:Executables()
	if empty(l:exes)
		call s:BuildError('no executable target in ' . g:build_dir . '/')
		return
	endif
	let l:exe = get(s:run_targets, getcwd(), '')
	if a:pick || index(l:exes, l:exe) < 0
		let l:exe = l:exes[0]
		if len(l:exes) > 1
			let l:choice = inputlist(['Run which target?']
				\ + map(copy(l:exes), {i, e -> printf('%d. %s', i + 1, e)}))
			if l:choice < 1 || l:choice > len(l:exes)
				return
			endif
			let l:exe = l:exes[l:choice - 1]
		endif
		let s:run_targets[getcwd()] = l:exe
	endif
	execute '!' . shellescape(g:build_dir . '/' . l:exe, 1)
		\ . (empty(a:args) ? '' : ' ' . a:args)
endfunction

command! -bar Build call s:Build()
command! -bang -nargs=* Run call s:Run(<bang>0, <q-args>)
nnoremap <silent> <F7> :Build<CR>
nnoremap <silent> <F5> :Run<CR>
nnoremap <silent> ]q :cnext<CR>
nnoremap <silent> [q :cprevious<CR>