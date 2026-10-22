#!/bin/sh
# lazygit <c-t> in the files panel: vimdiff the selected path.
# git difftool compares only tracked changes and quietly exits on a new file,
# so an untracked file is diffed against an empty one instead.
#
# Usage: lazygit-difftool.sh <path>

set -eu

path=$1

if [ ! -d "$path" ] && [ -z "$(git ls-files -- "$path")" ]; then
	empty=$(mktemp)
	trap 'rm -f "$empty"' EXIT
	vim -R -f -d -c 'wincmd l' "$empty" "$path"
elif git diff --quiet -- "$path"; then
	git difftool --no-prompt --cached -- "$path"
else
	git difftool --no-prompt -- "$path"
fi
