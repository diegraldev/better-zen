#!/bin/sh
set -eu

APP_ID="${ZEN_FLATPAK_ID:-app.zen_browser.zen}"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

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
if [ ! -d "$ZEN_ROOT/defaults/pref" ]; then
  echo "error: Zen application directory was not found at '$ZEN_ROOT'" >&2
  exit 1
fi

COPY_SCRIPT='
set -eu
SCRIPT_DIR=$1
ZEN_ROOT=$2
CFG="$ZEN_ROOT/mozilla.cfg"
PREF="$ZEN_ROOT/defaults/pref/zen-domain-only.js"

if [ -e "$CFG" ] && ! grep -qi "zen-domain-only\|Better Zen" "$CFG"; then
  echo "error: refusing to overwrite an unrelated AutoConfig file: $CFG" >&2
  exit 1
fi
if [ -e "$PREF" ] && ! grep -qi "zen-domain-only\|Better Zen" "$PREF"; then
  echo "error: refusing to overwrite an unrelated preference loader: $PREF" >&2
  exit 1
fi

install -m 0644 "$SCRIPT_DIR/mozilla.cfg" "$CFG"
install -m 0644 "$SCRIPT_DIR/zen-domain-only.js" "$PREF"
'

if [ "$(id -u)" -eq 0 ]; then
  sh -c "$COPY_SCRIPT" sh "$SCRIPT_DIR" "$ZEN_ROOT"
elif command -v pkexec >/dev/null 2>&1; then
  pkexec sh -c "$COPY_SCRIPT" sh "$SCRIPT_DIR" "$ZEN_ROOT"
else
  sudo sh -c "$COPY_SCRIPT" sh "$SCRIPT_DIR" "$ZEN_ROOT"
fi

echo "Installed domain-only URL bar files into the active Zen deployment."
echo "Restart Zen to apply the change. Reinstall after Zen Flatpak updates."
