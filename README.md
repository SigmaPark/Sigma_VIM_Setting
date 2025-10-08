# How To Setup VIM

1. Set .vimrc file 
```bash
$  ~/.vimrc 
```
or
```powershell
>  ${HOME}/_vimrc
```

2. Install Vundle if not exists.
```
git clone https://github.com/VundleVim/Vundle.vim.git $HOME\.vim\bundle\Vundle.vim
```

3. Execute VIM and type ":PluginInstall" then exit with ":q"


## Coc.nvim + clangd 

- Build coc.nvim
```
cd ~/.vim/bundle/coc.nvim
npm ci
```

- Go https://github.com/llvm/llvm-project and download release version.
```
LLVM-[version number]-win64.exe  # Windows
```
- Install it.
- Restart VIM and type ":CocInfo" to check if installed.


