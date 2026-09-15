#!/bin/sh
# Pager for delta on proot systems: drain stdin to a file, then page the file.
#
# Under proot a process blocked writing to a pipe never receives EPIPE or
# SIGPIPE, so quitting the pager early wedges whatever is still upstream --
# here git and delta both hang until killed. Reading to EOF before less starts
# means no pipe is ever closed from the reading end.
#
# Point delta at it with `git config --global delta.pager <path to this file>`.
# Only needed where that proot defect exists; elsewhere delta may page itself.

set -e

tmp=$(mktemp "${TMPDIR:-/tmp}/delta-pager.XXXXXX")
trap 'rm -f "$tmp"' EXIT INT TERM HUP
cat > "$tmp"
less -R "$tmp"
