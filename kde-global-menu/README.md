# KDE Global Menu — Zen Browser (Flatpak) en Wayland

Solución completa y documentada para hacer funcionar el widget **Global Menu** de KDE Plasma 6 con **Zen Browser instalado vía Flatpak** en Fedora (o cualquier distro KDE/Wayland).

---

## Contexto del problema

El widget `org.kde.plasma.appmenu` (Global Menu) en KDE Plasma 6 permite mostrar la barra de menú de las aplicaciones (File, Edit, View…) directamente en el panel del escritorio, en lugar de dentro de la ventana de la app.

**Zen Browser en Flatpak no aparecía en el Global Menu** a pesar de tener el widget instalado y configurado. La pantalla mostraba solo `•` (estado "sin menú detectado").

### Entorno afectado

| Componente | Versión |
|---|---|
| Zen Browser (Flatpak) | 1.21.10b (Firefox 153) |
| KDE Plasma | 6.6.4 |
| Fedora | 44 |
| Sesión | Wayland nativo |
| Runtime Flatpak | org.freedesktop.Platform 25.08 |

---

## Causa raíz — 3 capas apiladas

### Capa 1: `libdbusmenu` ausente del sandbox de Flatpak ❌

Zen Browser (basado en Firefox 138+) implementa el Global Menu de forma nativa sin depender de `appmenu-gtk-module`. El flujo es:

1. Firefox detecta `com.canonical.AppMenu.Registrar` en el D-Bus de sesión
2. Firefox carga **`libdbusmenu-gtk3.so.4`** y **`libdbusmenu-glib.so.4`** vía `dlopen()` para crear un servidor dbusmenu
3. El servidor expone el menú en el path D-Bus `/com/canonical/menu/0` bajo el nombre `org.mozilla.zen.<profile_hash>`
4. Firefox llama al protocolo Wayland `org_kde_kwin_appmenu_set_address(surface, service, path)` para decirle a KWin dónde está el menú
5. KWin notifica al panel, que lee los items del menú directamente del servicio D-Bus de Zen

**El problema**: El runtime `org.freedesktop.Platform/25.08` **no incluye** `libdbusmenu-gtk3` ni `libdbusmenu-glib`. El `dlopen()` fallaba silenciosamente, desactivando todo el feature sin ningún error visible.

### Capa 2: `LD_LIBRARY_PATH` con path incorrecto ❌

Al añadir `LD_LIBRARY_PATH` vía `flatpak override --env`, se asumió que el path XDG dentro del sandbox era `/home/user/.local/share/`. **Incorrecto.**

Dentro del sandbox de Flatpak, `$XDG_DATA_HOME` se mapea a:
```
/home/diegral/.var/app/app.zen_browser.zen/data/
```
(no a `~/.local/share/`). Esto lo confirma `/proc/PID/environ` del proceso real.

### Capa 3: Permisos D-Bus y Wayland faltantes ❌

El manifiesto Flatpak de Zen no incluye:
- `--talk-name=com.canonical.AppMenu.Registrar` → Firefox no puede detectar el registrar de KDE (el trigger que activa todo el feature)
- `MOZ_ENABLE_WAYLAND=1` → Sin esto, Zen puede usar XWayland en lugar de Wayland nativo, rompiendo el protocolo `org_kde_kwin_appmenu`

---

## Solución paso a paso

### Paso 1 — Activar los prefs de Firefox en `about:config`

En `about:config` de Zen Browser (o en `user.js`):

```javascript
user_pref("widget.gtk.global-menu.enabled", true);
user_pref("widget.gtk.global-menu.wayland.enabled", true);
```

El archivo `user.js` de este repo ya los incluye. Si los añades manualmente, van en:
```
~/.var/app/app.zen_browser.zen/.zen/<perfil>/user.js
```

### Paso 2 — Copiar las librerías dbusmenu al data dir de Flatpak

Las librerías `libdbusmenu-gtk3` y `libdbusmenu-glib` deben estar en tu sistema host (paquete `libdbusmenu` en Fedora):

```bash
# Verificar que existen en el sistema
ls /usr/lib64/libdbusmenu-gtk3.so.4.0.12
ls /usr/lib64/libdbusmenu-glib.so.4.0.12

# Crear el directorio lib dentro del data dir de Flatpak
mkdir -p ~/.var/app/app.zen_browser.zen/data/lib

# Copiar las librerías
cp /usr/lib64/libdbusmenu-gtk3.so.4.0.12 ~/.var/app/app.zen_browser.zen/data/lib/
cp /usr/lib64/libdbusmenu-glib.so.4.0.12 ~/.var/app/app.zen_browser.zen/data/lib/

# Crear los symlinks de soname
cd ~/.var/app/app.zen_browser.zen/data/lib/
ln -sf libdbusmenu-gtk3.so.4.0.12 libdbusmenu-gtk3.so.4
ln -sf libdbusmenu-glib.so.4.0.12 libdbusmenu-glib.so.4
```

> **Nota**: El script `install.sh` incluido en esta carpeta hace todo esto automáticamente.

### Paso 3 — Aplicar los overrides de Flatpak

```bash
# Forzar Wayland nativo
flatpak override --user --env=MOZ_ENABLE_WAYLAND=1 app.zen_browser.zen

# Permitir que Zen detecte el AppMenu Registrar de KDE via D-Bus
flatpak override --user --talk-name=com.canonical.AppMenu.Registrar app.zen_browser.zen

# Apuntar LD_LIBRARY_PATH al directorio con libdbusmenu
# IMPORTANTE: usar la ruta real que Flatpak ve dentro del sandbox
flatpak override --user --env=LD_LIBRARY_PATH=/home/$USER/.var/app/app.zen_browser.zen/data/lib app.zen_browser.zen
```

### Paso 4 — Reiniciar Zen

Cierra Zen completamente (todas las ventanas) y vuelve a abrirlo. Verifica en `about:support` que **Window Protocol = wayland**.

---

## Verificación

Una vez aplicada la solución, puedes verificar que todo funciona:

```bash
# 1. Confirmar que libdbusmenu está cargado en el proceso principal de Zen
MAIN_PID=$(pgrep -o -f "app.zen_browser.zen" 2>/dev/null)
grep dbusmenu /proc/$MAIN_PID/maps

# 2. Confirmar que el servicio D-Bus de Zen está activo
gdbus call --session \
  --dest org.freedesktop.DBus \
  --object-path /org/freedesktop/DBus \
  --method org.freedesktop.DBus.ListNames \
  2>/dev/null | tr ',' '\n' | grep mozilla.zen

# 3. Verificar que el menú tiene contenido
ZEN_SVC=$(gdbus call --session \
  --dest org.freedesktop.DBus \
  --object-path /org/freedesktop/DBus \
  --method org.freedesktop.DBus.ListNames \
  2>/dev/null | tr ',' '\n' | grep mozilla.zen | tr -d " '" | head -1)

gdbus call --session \
  --dest "$ZEN_SVC" \
  --object-path /com/canonical/menu/0 \
  --method com.canonical.dbusmenu.GetLayout \
  0 1 "[]"
# Debe devolver items: File, Edit, View, Spaces, History, Bookmarks, Tools, Help
```

### Estado final de overrides

```bash
flatpak override --user --show app.zen_browser.zen
```

Debe mostrar:
```ini
[Session Bus Policy]
com.canonical.AppMenu.Registrar=talk

[Environment]
LD_LIBRARY_PATH=/home/<usuario>/.var/app/app.zen_browser.zen/data/lib
MOZ_ENABLE_WAYLAND=1
```

---

## Script de instalación automática

Ver `install.sh` en esta carpeta. Ejecutar como usuario normal (sin sudo):

```bash
chmod +x install.sh
./install.sh
```

---

## Por qué esto es un workaround y no un fix permanente

El fix correcto sería que el equipo de Zen (o Flathub) añadiera al manifiesto `app.zen_browser.zen.yml`:

```yaml
finish-args:
  - --talk-name=com.canonical.AppMenu.Registrar   # falta
  - --env=MOZ_ENABLE_WAYLAND=1                    # falta

# Y bundlear libdbusmenu en el Flatpak:
modules:
  - name: libdbusmenu
    ...
```

Issues relevantes:
- [zen-browser/desktop #5171](https://github.com/zen-browser/desktop/discussions/5171) — Discussion sobre Global Menu en Flatpak
- [zen-browser/desktop #12024](https://github.com/zen-browser/desktop/issues/12024) — Bug conocido en Linux con el menú de Spaces (workaround en el código de Zen)

**Si Zen se actualiza vía Flatpak**: las librerías en `data/lib/` sobreviven la actualización (son del usuario, no del runtime). Los overrides también persisten. Solo podría romperse si el runtime de Flatpak o la estructura interna de Zen cambia significativamente.

---

## Arquitectura técnica para futuros agentes

```
Zen Browser (Flatpak sandbox)
│
├── DBUS_SESSION_BUS_ADDRESS=unix:path=/run/flatpak/bus  ← proxy de Flatpak
│   └── xdg-dbus-proxy
│       ├── --talk-name=com.canonical.AppMenu.Registrar  ← permite detectar KDE registrar
│       └── org.mozilla.zen.*=own                         ← Zen puede registrar este nombre
│
├── LD_LIBRARY_PATH=/home/user/.var/app/app.zen_browser.zen/data/lib
│   ├── libdbusmenu-gtk3.so.4  ← servidor dbusmenu (expone menú vía D-Bus)
│   └── libdbusmenu-glib.so.4  ← dep de gtk3
│
└── libxul.so (Firefox core)
    ├── dlopen("libdbusmenu-gtk3.so.4")  ← carga las libs de data/lib/
    ├── dbusmenu_server_new("/com/canonical/menu/0")
    ├── Expone menú en: org.mozilla.zen.<hash> @ /com/canonical/menu/0
    └── org_kde_kwin_appmenu_set_address(surface, service, path)  ← Wayland protocol

KWin (compositor Wayland)
└── Recibe set_address → asocia menú a la ventana de Zen
    └── Notifica a kded6 appmenu module
        └── Notifica a org.kde.plasma.appmenu (panel widget)
            └── Llama GetLayout en org.mozilla.zen.<hash> @ /com/canonical/menu/0
                └── Muestra: File | Edit | View | Spaces | History | Bookmarks | Tools | Help ✅
```
