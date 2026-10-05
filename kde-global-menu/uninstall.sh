#!/usr/bin/env bash
# =============================================================================
# uninstall.sh — Revertir KDE Global Menu fix para Zen Browser (Flatpak)
# =============================================================================

set -e

APP_ID="app.zen_browser.zen"
DATA_LIB="$HOME/.var/app/$APP_ID/data/lib"

GRN='\033[0;32m'
YLW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GRN}[+]${NC} $1"; }
warn() { echo -e "${YLW}[!]${NC} $1"; }

echo ""
echo "Revirtiendo KDE Global Menu fix para Zen Browser..."
echo ""

info "Eliminando librerías de $DATA_LIB..."
rm -fv "$DATA_LIB/libdbusmenu-gtk3.so.4"*
rm -fv "$DATA_LIB/libdbusmenu-glib.so.4"*

info "Eliminando Flatpak overrides..."
flatpak override --user --unset-env=MOZ_ENABLE_WAYLAND "$APP_ID" 2>/dev/null || true
flatpak override --user --unset-env=LD_LIBRARY_PATH "$APP_ID" 2>/dev/null || true
flatpak override --user --no-talk-name=com.canonical.AppMenu.Registrar "$APP_ID" 2>/dev/null || true

info "Estado de overrides tras revertir:"
flatpak override --user --show "$APP_ID" || echo "(sin overrides)"

warn "Reinicia Zen para aplicar los cambios."
echo ""
