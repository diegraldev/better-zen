#!/usr/bin/env bash
# =============================================================================
# install.sh — KDE Global Menu para Zen Browser (Flatpak) en Wayland
# =============================================================================
# Ejecutar como usuario normal (sin sudo).
# Lee el README.md de esta carpeta para entender qué hace cada paso.
# =============================================================================

set -e

APP_ID="app.zen_browser.zen"
DATA_LIB="$HOME/.var/app/$APP_ID/data/lib"
LIB_SRC_DIR="/usr/lib64"

RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GRN}[+]${NC} $1"; }
warn()  { echo -e "${YLW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║   KDE Global Menu — Zen Browser Flatpak (Wayland)   ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# --- Paso 1: Verificar libdbusmenu en el sistema host ---
info "Verificando libdbusmenu en el sistema host..."

GTK3_LIB=$(ls "$LIB_SRC_DIR"/libdbusmenu-gtk3.so.4.*.* 2>/dev/null | head -1)
GLIB_LIB=$(ls "$LIB_SRC_DIR"/libdbusmenu-glib.so.4.*.* 2>/dev/null | head -1)

if [ -z "$GTK3_LIB" ] || [ -z "$GLIB_LIB" ]; then
    warn "No se encontraron las librerías en $LIB_SRC_DIR"
    warn "Intentando instalar libdbusmenu (requiere contraseña sudo)..."
    if command -v dnf &>/dev/null; then
        sudo dnf install -y libdbusmenu libdbusmenu-gtk3
    elif command -v apt &>/dev/null; then
        sudo apt install -y libdbusmenu-gtk3-4 libdbusmenu-glib4
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm libdbusmenu-gtk3
    else
        error "No se pudo instalar libdbusmenu. Instálalo manualmente y vuelve a ejecutar."
    fi
    GTK3_LIB=$(ls "$LIB_SRC_DIR"/libdbusmenu-gtk3.so.4.*.* 2>/dev/null | head -1)
    GLIB_LIB=$(ls "$LIB_SRC_DIR"/libdbusmenu-glib.so.4.*.* 2>/dev/null | head -1)
    [ -z "$GTK3_LIB" ] && error "libdbusmenu-gtk3 no encontrado tras instalación."
    [ -z "$GLIB_LIB" ] && error "libdbusmenu-glib no encontrado tras instalación."
fi

info "  libdbusmenu-gtk3: $GTK3_LIB"
info "  libdbusmenu-glib: $GLIB_LIB"

# --- Paso 2: Crear directorio y copiar librerías ---
info "Creando directorio $DATA_LIB..."
mkdir -p "$DATA_LIB"

info "Copiando librerías al data dir de Flatpak..."
cp -v "$GTK3_LIB" "$DATA_LIB/"
cp -v "$GLIB_LIB" "$DATA_LIB/"

GTK3_BASENAME=$(basename "$GTK3_LIB")
GLIB_BASENAME=$(basename "$GLIB_LIB")

# Crear symlinks de soname
(cd "$DATA_LIB" && ln -sf "$GTK3_BASENAME" libdbusmenu-gtk3.so.4)
(cd "$DATA_LIB" && ln -sf "$GLIB_BASENAME" libdbusmenu-glib.so.4)
info "Symlinks creados:"
ls -la "$DATA_LIB/"

# --- Paso 3: Aplicar Flatpak overrides ---
info "Aplicando Flatpak overrides..."

flatpak override --user \
    --env=MOZ_ENABLE_WAYLAND=1 \
    --env=LD_LIBRARY_PATH="$HOME/.var/app/$APP_ID/data/lib" \
    --talk-name=com.canonical.AppMenu.Registrar \
    "$APP_ID"

info "Overrides aplicados:"
flatpak override --user --show "$APP_ID"

# --- Paso 4: Activar prefs de Firefox ---
PROFILE_DIR=$(ls -d "$HOME/.var/app/$APP_ID/.zen/"*.Default* 2>/dev/null | head -1)

if [ -n "$PROFILE_DIR" ]; then
    USER_JS="$PROFILE_DIR/user.js"
    info "Activando prefs en $USER_JS..."

    # Añadir solo si no existen ya
    if ! grep -q "widget.gtk.global-menu.enabled" "$USER_JS" 2>/dev/null; then
        cat >> "$USER_JS" <<'EOF'

// KDE Global Menu — Habilitan la exportación del menú al Global Menu de KDE Plasma
user_pref("widget.gtk.global-menu.enabled", true);
user_pref("widget.gtk.global-menu.wayland.enabled", true);
EOF
        info "Prefs añadidos a user.js"
    else
        info "Prefs ya presentes en user.js, omitiendo."
    fi
else
    warn "No se encontró el perfil de Zen. Añade manualmente en about:config:"
    warn "  widget.gtk.global-menu.enabled = true"
    warn "  widget.gtk.global-menu.wayland.enabled = true"
fi

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║                   ✅  INSTALADO                      ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
warn "Cierra Zen completamente y vuelve a abrirlo para aplicar los cambios."
warn "Verifica en about:support que 'Window Protocol' sea 'wayland'."
echo ""
