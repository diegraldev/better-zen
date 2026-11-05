#!/bin/sh
set -eu

APP_ID="${ZEN_FLATPAK_ID:-app.zen_browser.zen}"

if ! command -v flatpak >/dev/null 2>&1; then
  echo "error: flatpak is not installed or not in PATH" >&2
  exit 1
fi

LOCATION="$(flatpak info --show-location "$APP_ID" 2>/dev/null || true)"
if [ -z "$LOCATION" ]; then
  echo "error: Flatpak application '$APP_ID' was not found" >&2
  exit 1
fi

ZEN_ROOT="$LOCATION/files/zen"
REMOVE_SCRIPT='
set -eu
ZEN_ROOT=$1
CFG="$ZEN_ROOT/mozilla.cfg"
PREF="$ZEN_ROOT/defaults/pref/zen-domain-only.js"

if [ -e "$CFG" ] && ! grep -qi "zen-domain-only\|Better Zen" "$CFG"; then
  echo "error: refusing to remove an unrelated AutoConfig file: $CFG" >&2
  exit 1
fi
if [ -e "$PREF" ] && ! grep -qi "zen-domain-only\|Better Zen" "$PREF"; then
  echo "error: refusing to remove an unrelated preference loader: $PREF" >&2
  exit 1
fi

rm -f "$CFG" "$PREF"
'

if [ "$(id -u)" -eq 0 ]; then
  sh -c "$REMOVE_SCRIPT" sh "$ZEN_ROOT"
elif command -v pkexec >/dev/null 2>&1; then
  pkexec sh -c "$REMOVE_SCRIPT" sh "$ZEN_ROOT"
else
  sudo sh -c "$REMOVE_SCRIPT" sh "$ZEN_ROOT"
fi

echo "Removed the domain-only URL bar files. Restart Zen to apply the change."
