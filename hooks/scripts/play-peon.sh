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

# --- Cooldown check (work category: 30s cooldown) ---
COOLDOWN_DIR="/tmp/peon-notifications"
mkdir -p "$COOLDOWN_DIR"

if [[ "$CATEGORY" == "work" ]]; then
  COOLDOWN_FILE="$COOLDOWN_DIR/work_last_played"
  COOLDOWN_SECONDS=30

  if [[ -f "$COOLDOWN_FILE" ]]; then
    LAST_PLAYED=$(cat "$COOLDOWN_FILE")
    NOW=$(date +%s)
    ELAPSED=$((NOW - LAST_PLAYED))
    if [[ $ELAPSED -lt $COOLDOWN_SECONDS ]]; then
      exit 0
    fi
  fi

  date +%s > "$COOLDOWN_FILE"
fi

# --- Stop hook infinite loop prevention ---
# When a Stop event fires, playing audio could trigger another Stop event.
# Use a lock file to prevent re-entry.
if [[ "$CATEGORY" == "stop" ]]; then
  LOCK_FILE="$COOLDOWN_DIR/stop_hook_active"

  if [[ -f "$LOCK_FILE" ]]; then
    # Another stop hook is already playing, skip
    exit 0
  fi

  touch "$LOCK_FILE"
  # Clean up lock file after a short delay (background)
  (sleep 5 && rm -f "$LOCK_FILE") &
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
