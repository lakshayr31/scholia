#!/usr/bin/env bash
# open-browser.sh — open a file in the system default browser across
# macOS, Linux, and Windows (Git Bash / Cygwin).
#
# Usage: open-browser.sh <path-to-file>
#
# Requires bash: it branches on $OSTYPE, which is a bash-only variable.

file="$1"

if [[ "$OSTYPE" == darwin* ]]; then
  open "$file"
elif [[ "$OSTYPE" == linux-gnu* ]]; then
  xdg-open "$file"
elif [[ "$OSTYPE" == msys* || "$OSTYPE" == cygwin* ]]; then
  start "$file"
else
  echo "open-browser.sh: unsupported platform \"$OSTYPE\" — please open \"$file\" in your browser manually." >&2
  exit 1
fi
