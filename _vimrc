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
	" Plugin 'yuttie/comfortable-motion.vim'	" off: scrolling felt too slow
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
let mapleader = " " " <Space> as <leader>; must precede every <leader> mapping
nnoremap <leader>n :NERDTreeToggle<cr>
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
		\     'CocSemTypeKeyword', 'CocSemTypeModifier', 'VsKeywordOp'],
		\ '#9B9B9B': ['PreProc', 'Include', 'Define', 'Macro', 'PreCondit'],
		\ '#C8C8C8': ['Identifier', 'Function', 'CocSemTypeNamespace', 'CocSemTypeVariable',
		\     'CocSemTypeFunction', 'CocSemTypeMethod', 'CocSemTypeLabel'],
		\ '#4EC9B0': ['CocSemTypeType', 'CocSemTypeClass', 'CocSemTypeStruct',
		\     'CocSemTypeEnum', 'CocSemTypeInterface', 'CocSemTypeTypeParameter',
		\     'CocSemTypeConcept', 'VsStlType'],
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
	" Without clangd's tokens vim-cpp-modern paints std *_t names as Typedef/Type (blue)
	" and *_v variable templates as Boolean (blue); VS draws types teal, variables plain.
	for l:group in ['cppSTLtypedef', 'cppSTLenum', 'cppSTLconcept', 'cppSTLtype',
		\ 'cppSTLiterator', 'cppSTLexception']
		execute 'highlight link ' . l:group . ' VsStlType'
	endfor
	highlight link cppSTLbool Identifier
endfunction

augroup VsDarkColors
	autocmd!
	autocmd ColorScheme codedark call s:VsDarkColors()
	" sizeof and friends are cOperator/cppOperator, which codedark paints as plain
	" text like + and =; VS draws just these keywords blue. Re-declaring the words
	" in our own group overrides the earlier definition, symbols stay untouched.
	autocmd Syntax c,cpp,cuda syntax keyword VsKeywordOp sizeof alignof typeid new delete static_assert
augroup END

" Trailing whitespace shows as red cells, like the lazygit diff preview;
" while typing, the run right before the cursor is spared.
augroup TrailingWhitespace
	autocmd!
	autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
	autocmd BufWinEnter,InsertLeave * match ExtraWhitespace /\s\+$/
	autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
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
	" A vimdiff (git difftool, lazygit <c-t>) is a throwaway view; saving it
	" would replace the session the next bare `vim` restores.
	if &diff
		return
	endif
	call mkdir(g:session_dir, 'p')
	execute 'mksession! ' . fnameescape(s:SessionFile())
endfunction

augroup AutoSession
	autocmd!
	autocmd VimEnter * nested call s:RestoreSession()
	autocmd VimLeave * call s:SaveSession()
augroup END

" ---- Build & run: CMake + Ninja + MSVC ----
" Start vim in the project root, the directory that holds CMakeLists.txt.
"   <C-F7>  :Build          configure with Ninja when needed, then build
"           :Preset [name]  choose the CMake preset the keys below use
"   <C-F6>  :Clean          delete the build outputs, keep the configuration
"   <C-F5>  :Run [args]     build, then run the executable target
"           :Run! [args]    pick the target again (asked when there are several)
"   <F5>    :Debug          open the project in VSCode and debug it there
"   ]q / [q                 next / previous entry in the error list
" Without a CMakePresets.json the directory below is used as it is.
let g:build_dir = 'build'

" The configure presets of CMakePresets.json and CMakeUserPresets.json: a
" dictionary of preset name to build directory, relative to the project root.
" binaryDir is inherited, so a preset without one takes its parent's.
function! s:PresetBinaryDir(raw, name, depth) abort
	let l:preset = get(a:raw, a:name, {})
	if has_key(l:preset, 'binaryDir')
		return l:preset.binaryDir
	endif
	if a:depth > 16
		return ''
	endif
	let l:parents = get(l:preset, 'inherits', [])
	for l:parent in type(l:parents) == v:t_list ? l:parents : [l:parents]
		let l:dir = s:PresetBinaryDir(a:raw, l:parent, a:depth + 1)
		if !empty(l:dir)
			return l:dir
		endif
	endfor
	return ''
endfunction

function! s:ConfigurePresets() abort
	let l:raw = {}
	for l:file in ['CMakePresets.json', 'CMakeUserPresets.json']
		if !filereadable(l:file)
			continue
		endif
		try
			let l:json = json_decode(join(readfile(l:file), "\n"))
		catch
			call s:BuildError(l:file . ' is not valid JSON')
			continue
		endtry
		for l:preset in get(l:json, 'configurePresets', [])
			let l:raw[l:preset.name] = l:preset
		endfor
	endfor
	let l:found = {}
	for l:name in keys(l:raw)
		if get(l:raw[l:name], 'hidden', v:false)
			continue
		endif
		let l:dir = s:PresetBinaryDir(l:raw, l:name, 0)
		let l:dir = substitute(l:dir, '^\${sourceDir}/', '', '')
		let l:dir = substitute(l:dir, '\${presetName}', l:name, 'g')
		if !empty(l:dir) && l:dir !~# '\${'
			let l:found[l:name] = l:dir
		endif
	endfor
	return l:found
endfunction

" The preset chosen per project root, so it is asked for only once.
let s:presets = {}

" [preset name, build directory] for the project in the working directory.
" The name is empty when there are no presets and g:build_dir applies. With
" several presets and no choice yet, 'default' is taken, else the user is asked.
function! s:Target() abort
	let l:all = s:ConfigurePresets()
	if empty(l:all)
		return ['', g:build_dir]
	endif
	let l:name = get(s:presets, getcwd(), '')
	if !has_key(l:all, l:name)
		let l:names = sort(keys(l:all))
		if has_key(l:all, 'default')
			let l:name = 'default'
		elseif len(l:names) == 1
			let l:name = l:names[0]
		else
			let l:choice = inputlist(['Which CMake preset?']
				\ + map(copy(l:names), {i, n -> printf('%d. %s', i + 1, n)}))
			if l:choice < 1 || l:choice > len(l:names)
				let l:name = l:names[0]
			else
				let l:name = l:names[l:choice - 1]
			endif
		endif
		let s:presets[getcwd()] = l:name
	endif
	return [l:name, l:all[l:name]]
endfunction

function! s:Preset(name) abort
	let l:all = s:ConfigurePresets()
	if empty(l:all)
		call s:BuildError('no configure presets here: start vim in the project root')
		return
	endif
	if empty(a:name)
		let [l:current, l:dir] = s:Target()
		echo 'Build preset: ' . l:current . ' (' . l:dir . '/)'
		for l:other in sort(keys(l:all))
			echo (l:other ==# l:current ? '* ' : '  ') . l:other . '  ' . l:all[l:other] . '/'
		endfor
		return
	endif
	if !has_key(l:all, a:name)
		call s:BuildError('no configure preset named ' . a:name)
		return
	endif
	let s:presets[getcwd()] = a:name
	echo 'Build preset: ' . a:name . ' (' . l:all[a:name] . '/)'
endfunction

function! s:PresetNames(lead, line, pos) abort
	return filter(sort(keys(s:ConfigurePresets())), {_, n -> n =~# '^' . a:lead})
endfunction

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
function! s:Configure(preset, dir) abort
	if filereadable(a:dir . '/build.ninja')
		return 1
	endif
	" A configure that failed leaves its cache behind; only another generator's
	" cache is a reason to stop.
	let l:cache = a:dir . '/CMakeCache.txt'
	if filereadable(l:cache)
		\ && empty(filter(readfile(l:cache), {_, l -> l =~# '^CMAKE_GENERATOR:INTERNAL=Ninja$'}))
		call s:BuildError(a:dir
			\ . '/ was configured for another generator; remove it to switch to Ninja')
		return 0
	endif
	if empty(a:preset)
		execute '!cmake -S . -B ' . shellescape(a:dir, 1)
			\ . ' -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON'
	else
		execute '!cmake --preset ' . shellescape(a:preset, 1)
	endif
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
	let [l:preset, l:dir] = s:Target()
	if !s:ImportMsvcEnv() || !s:Configure(l:preset, l:dir)
		return 0
	endif
	silent! wall
	let l:saved = [&makeprg, &errorformat, &makeencoding]
	" cmake --build drives the ninja recorded in CMakeCache.txt. Ninja 1.12
	" (bundled with Visual Studio) and 1.13 each delete the other's .ninja_log,
	" so building with whichever ninja comes first on PATH would force a full
	" rebuild every time VSCode and vim take turns on one build directory.
	let &makeprg = 'cmake --build ' . shellescape(l:dir)
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
	echo 'Build succeeded' . (empty(l:preset) ? '' : ' (preset ' . l:preset . ')')
	return 1
endfunction

" Executable targets as ninja lists them, relative to the build directory.
function! s:Executables(dir) abort
	let l:exes = []
	for l:line in systemlist('ninja -C ' . shellescape(a:dir) . ' -t targets all')
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
	let l:dir = s:Target()[1]
	let l:exes = s:Executables(l:dir)
	if empty(l:exes)
		call s:BuildError('no executable target in ' . l:dir . '/')
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
	execute '!' . shellescape(l:dir . '/' . l:exe, 1)
		\ . (empty(a:args) ? '' : ' ' . a:args)
endfunction

function! s:Clean() abort
	let l:dir = s:Target()[1]
	if !filereadable(l:dir . '/build.ninja')
		echo 'Nothing to clean: ' . l:dir . '/ is not configured'
		return
	endif
	" Cleaning can regenerate build.ninja when CMakeLists.txt changed, and that
	" needs the compiler.
	if !s:ImportMsvcEnv()
		return
	endif
	let l:output = system('cmake --build ' . shellescape(l:dir) . ' --target clean')
	if v:shell_error
		call s:BuildError('Clean failed: ' . trim(l:output))
		return
	endif
	echo 'Clean succeeded'
endfunction

" vim has no debugger that reads MSVC's PDBs, so the session goes to VSCode.
" A request file tells the vim-debug-bridge extension (vscode-debug-bridge/)
" which window should start debugging; `code` then opens or raises that window.
let g:vscode_debug_queue = expand('$HOME/.vim/vscode-debug')

function! s:Debug() abort
	if !filereadable('CMakeLists.txt')
		call s:BuildError('no CMakeLists.txt here: start vim in the project root')
		return
	endif
	if !executable('code')
		call s:BuildError('VSCode (code) is not on PATH')
		return
	endif
	silent! wall
	let l:root = trim(system('cygpath -w ' . shellescape(getcwd())))
	let l:target = fnamemodify(get(s:run_targets, getcwd(), ''), ':t:r')
	call mkdir(g:vscode_debug_queue, 'p')
	let l:request = g:vscode_debug_queue . '/' . localtime() . '-' . getpid() . '.json'
	" Written aside, then renamed, so the extension never reads half a file.
	call writefile([json_encode({'folder': l:root, 'target': l:target, 'time': localtime()})],
		\ l:request . '.tmp')
	call rename(l:request . '.tmp', l:request)
	let l:args = [l:root]
	if !empty(expand('%'))
		call add(l:args, '--goto')
		call add(l:args, trim(system('cygpath -w ' . shellescape(expand('%:p')))) . ':' . line('.'))
	endif
	call system('code ' . join(map(l:args, {_, a -> shellescape(a)})))
	echo 'Debugging in VSCode...'
endfunction

command! -bar Build call s:Build()
command! -bar Clean call s:Clean()
command! -nargs=? -complete=customlist,s:PresetNames Preset call s:Preset(<q-args>)
command! -bang -nargs=* Run call s:Run(<bang>0, <q-args>)
command! -bar Debug call s:Debug()
nnoremap <silent> <C-F7> :Build<CR>
nnoremap <silent> <C-F6> :Clean<CR>
nnoremap <silent> <C-F5> :Run<CR>
nnoremap <silent> <F5> :Debug<CR>
nnoremap <silent> ]q :cnext<CR>
nnoremap <silent> [q :cprevious<CR>