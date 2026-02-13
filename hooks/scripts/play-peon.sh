#!/usr/bin/env bash
# Voice notification player for Claude Code hooks
# Usage: play-peon.sh <category>
# Categories: session_start, stop, user_prompt, work, notification

set -euo pipefail

CATEGORY="${1:-}"
if [[ -z "$CATEGORY" ]]; then
  exit 0
fi

# Resolve plugin root directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SOUNDS_DIR="$PLUGIN_ROOT/sounds/$CATEGORY"

# Exit silently if no sounds directory or no sound files
if [[ ! -d "$SOUNDS_DIR" ]]; then
  exit 0
fi

# Find all MP3/WAV files in the category directory
shopt -s nullglob
SOUND_FILES=("$SOUNDS_DIR"/*.{mp3,wav,m4a,aiff})
shopt -u nullglob

if [[ ${#SOUND_FILES[@]} -eq 0 ]]; then
  exit 0
fi

# --- Random sound selection ---
RANDOM_INDEX=$((RANDOM % ${#SOUND_FILES[@]}))
SELECTED="${SOUND_FILES[$RANDOM_INDEX]}"

# --- Play sound (fully detached, cross-platform) ---
if [[ "$(uname)" == "Darwin" ]]; then
  (afplay "$SELECTED" &>/dev/null &)
elif command -v paplay &>/dev/null; then
  (paplay "$SELECTED" &>/dev/null &)
elif command -v mpv &>/dev/null; then
  (mpv --no-terminal "$SELECTED" &>/dev/null &)
elif command -v aplay &>/dev/null; then
  (aplay -q "$SELECTED" &>/dev/null &)
fi

exit 0
