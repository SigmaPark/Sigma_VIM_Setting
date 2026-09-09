#!/bin/sh
# Sync a live vim config to this repo's canonical profile.
#
# By default this creates a symlink, so future edits to the profile file in
# this repo take effect immediately without re-running anything. If symlinks
# aren't available (e.g. Windows without Developer Mode / admin rights), it
# falls back to a plain copy — re-run this script after pulling repo updates
# to pick those up.
#
# Usage: sh sync.sh <posix|lite|windows> [target-path]

set -eu

# On Windows/Git-Bash, plain `ln -s` silently falls back to a copy (still
# exits 0) unless this is set, which would make the "Linked" message below
# a lie. Harmless no-op on POSIX shells.
export MSYS=winsymlinks:nativestrict

profile=${1:-}
repo_dir=$(cd "$(dirname "$0")" && pwd)

case "$profile" in
	posix)   src="$repo_dir/.vimrc";      default_target="$HOME/.vimrc" ;;
	lite)    src="$repo_dir/.vimrc.lite"; default_target="$HOME/.vimrc" ;;
	windows) src="$repo_dir/_vimrc";      default_target="$HOME/_vimrc" ;;
	*)
		echo "Usage: sh sync.sh <posix|lite|windows> [target-path]" >&2
		exit 1
		;;
esac

target=${2:-$default_target}

if [ -e "$target" ] || [ -L "$target" ]; then
	if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
		echo "Already linked: $target -> $src"
		exit 0
	fi
	backup="$target.bak.$(date +%Y%m%d-%H%M%S)"
	mv "$target" "$backup"
	echo "Existing $target backed up to $backup"
fi

if ln -s "$src" "$target" 2>/dev/null; then
	echo "Linked $target -> $src"
else
	cp "$src" "$target"
	echo "Symlink not available; copied $src -> $target instead."
	echo "Re-run this script after pulling repo updates to refresh it."
fi
