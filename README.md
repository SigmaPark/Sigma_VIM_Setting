# How To Setup VIM

1. Point your live config at a profile with `sync.sh` — it symlinks so future
   edits in this repo take effect immediately, without copying again:
```bash
sh sync.sh posix    # ~/.vimrc  -> .vimrc
sh sync.sh lite     # ~/.vimrc  -> .vimrc.lite  (slow / low-end devices)
sh sync.sh windows  # ~/_vimrc  -> _vimrc
```
   An existing plain file at the target path is backed up (`.bak.<timestamp>`)
   before the symlink is made. Where symlinks aren't available (e.g. Windows
   without Developer Mode), it falls back to a plain copy — re-run the script
   after `git pull` to refresh it.

2. Install Vundle if not exists.
```
git clone https://github.com/VundleVim/Vundle.vim.git $HOME\.vim\bundle\Vundle.vim
```

3. Execute VIM and type ":PluginInstall" then exit with ":q"


## Coc.nvim + clangd

**Vundle cannot select a branch.** `Plugin` only understands `rtp`, `pinned` and
`name`, so `{'branch': 'release'}` is silently ignored. coc.nvim ships its
prebuilt bundle only on `release`, so clone that branch by hand and let Vundle
leave it alone (`{'pinned': 1}` in the vimrc):

```bash
git clone --branch release --depth 1     https://github.com/neoclide/coc.nvim.git ~/.vim/bundle/coc.nvim
```

The `release` branch already contains `build/index.js` — **no `npm ci` needed**.
Requires node 16+ (`node --version`).

### clangd

Do **not** rely on `:CocCommand clangd.install`. coc runs extensions inside a
sandbox that has no bare `AbortController`, so coc-clangd's auto-installer dies
with `ReferenceError: AbortController is not defined` before it ever reaches
GitHub. Install the binary yourself — the standalone release is ~27 MB, far
lighter than the full LLVM toolchain:

- Download `clangd-windows-<ver>.zip` (or `-linux-`, `-mac-`) from
  <https://github.com/clangd/clangd/releases> and unpack it, e.g. to
  `~/.local/clangd/`.
- Then `:CocInstall coc-clangd`, and point it at the binary.

### coc-settings.json

Use **coc-clangd's own keys**. Do not add a manual `languageserver.clangd`
block: the extension and the hand-written server entry both claim C/C++ and coc
warns about the conflict.

```json
{
  "clangd.path": "C:/Users/<you>/.local/clangd/bin/clangd.exe",
  "clangd.checkUpdates": false,
  "clangd.arguments": ["--background-index", "--header-insertion=never"]
}
```

clangd finds its flags in `compile_commands.json` (CMake:
`-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`, or the Ninja generator by default). With
an MSVC compile database it enters `--driver-mode=cl` and locates the MSVC and
Windows SDK headers on its own — no Developer Command Prompt required.

Verify without opening vim:

```bash
clangd --check=path/to/file.cpp --compile-commands-dir=path/to/build
```

**On Windows, coc reads `coc-settings.json` from `~/vimfiles`, not `~/.vim`.**
The vimrc sets `g:coc_config_home` so both platforms share `~/.vim`.

## Buffer-based navigation

All three profiles favor buffers over window splits for juggling open files —
`:vs` pays a real scroll cost (see the gotcha below), so the day-to-day flow
is one full-width window and `]b` / `[b` to cycle buffers:

```
]b   next buffer
[b   previous buffer
```

Bracket mappings were picked to match the existing `[g` / `]g` diagnostic
jumps and to stay clear of `<Tab>` / `<S-Tab>`, which coc already owns for
completion-popup navigation in insert mode.

### comfortable-motion tuning

All three profiles raise `g:comfortable_motion_friction` and
`g:comfortable_motion_air_drag` above the plugin defaults (80.0 / 2.0) to
140.0 / 5.0. Friction is a constant deceleration and air_drag is
velocity-proportional; both were low enough by default that a fast scroll
kept gliding at low speed instead of stopping. The higher pair keeps the
animation but cuts that drag tail short.

## Session persistence

All three profiles remember what was open. Launching `vim` with **no file
arguments** restores the previous session (`~/.vim/session.vim`); launching
it with a file (`vim foo.cpp`) leaves the argument list alone, same as
always. The session file is rewritten on every `vim` exit, so whatever is
open when you quit is what a bare `vim` reopens next time — no manual
`:mksession` / `:source` needed.

## Lightweight profile (slow / low-end devices)

`.vimrc.lite` is a trimmed variant for low-end devices (e.g. a tablet
terminal running over proot). It keeps `comfortable-motion` — measured smooth
once vertical splits are avoided, see the gotcha below — and adds `ttyfast` /
`lazyredraw`. IntelliSense (coc.nvim + clangd) is kept intact.

```bash
sh sync.sh lite                # or: vim -u /path/to/.vimrc.lite
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




## Gotcha: vertical splits kill scrolling in a terminal

A terminal's scroll region is a **row range** — it cannot be split vertically.
With one full-width window vim scrolls by sending a single escape sequence. With
a vertical split (`:vs`, or any side panel such as NERDTree) that would drag the
neighbouring window along, so vim has to **repaint every affected cell** instead.
On a 240x89 terminal that is roughly 21,000 cells per scroll step, each one
needing its syntax highlighting recomputed.

The cost is paid *while scrolling*, not merely by having the split open, so a
side-by-side comparison you only read through is fine.

| want | use | speed |
|---|---|---|
| two files at once, stacked | `:sp` | fast |
| one file at a time, full screen | `:tabnew` / `gt` | fast |
| two files side by side | `:vs` | **slow while scrolling** |
| side by side *and* fast | two terminal panes, one vim each | fast, but nothing is shared |

Within a single vim, buffers, registers, marks and undo are all shared, so `gt`
plus `:b <name>` moves a file between tabs with no copying. Two separate vim
processes are fast and side by side but share only the system clipboard
(`"+y` / `"+p`). You cannot have side-by-side, fast, and shared state at once.

On a tablet, hold the device in portrait and split horizontally.

### Diagnosing a slow vim

- `:ls` hides `nobuflisted` buffers — NERDTree's window will not appear. Use `:ls!`.
- `:profile` only measures **vimscript**. A plugin showing zero calls is not
  exonerated; redraw and syntax cost live in vim's C core where the profiler
  cannot see them.
- `vim --startuptime` inflates every measurement by ~2 s when stdout is not a
  terminal (vim prints "Output is not to a terminal" and sleeps). Run it from a
  real terminal.
- `vim -u <file>` skips the **system** vimrc (`/etc/vimrc`) as well as the user
  one, so a bisection ladder built with `-u` silently omits it.
