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


## Lightweight profile (slow / low-end devices)

`.vimrc.lite` is a trimmed variant for machines where smooth animation
stutters (e.g. a tablet terminal running over proot). It drops
`comfortable-motion` so scrolling is instant instead of animated, and enables
`ttyfast` / `lazyredraw`. IntelliSense (coc.nvim + clangd) is kept intact.

```bash
cp .vimrc.lite ~/.vimrc        # or: vim -u /path/to/.vimrc.lite
```

Note: coc.nvim ships its prebuilt bundle on the `release` branch. If Vundle
leaves it on `master` (source only), check it out manually:
```bash
cd ~/.vim/bundle/coc.nvim && git fetch origin release && git checkout -B release FETCH_HEAD
```
For C/C++, this profile drives clangd via `~/.vim/coc-settings.json`:
```json
{
  "languageserver": {
    "clangd": { "command": "clangd", "filetypes": ["c", "cpp", "objc", "objcpp"] }
  }
}
```


