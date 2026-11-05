# KDE Plasma Global Menu for Zen Flatpak

This optional workaround exports Zen Browser's application menu to the KDE
Plasma Global Menu widget on a Wayland session. It is intended for Zen's system
Flatpak installation.

## Background

Firefox-based browsers can expose their menu through the `com.canonical.AppMenu`
D-Bus protocol. In the tested Zen Flatpak environment, the feature did not work
because the runtime lacked the `libdbusmenu` libraries, the Flatpak did not
have permission to contact KDE's AppMenu registrar, and Zen was not consistently
using native Wayland.

The workaround copies the host `libdbusmenu-gtk3` and `libdbusmenu-glib`
libraries into Zen's Flatpak data directory, adds the required Flatpak overrides,
and enables the Firefox global-menu preferences.

## Tested environment

The original configuration was tested with Zen Browser 1.21.10b, KDE Plasma
6.6.4, Fedora 44, Wayland, and the Freedesktop 25.08 Flatpak runtime. Other
versions and distributions may require changes. In particular, the installer
currently looks for host libraries under `/usr/lib64`.

## Install

Run the installer as your regular user; it may request `sudo` if the libraries
are missing:

```sh
./install.sh
```

The script copies libraries to
`~/.var/app/app.zen_browser.zen/data/lib`, applies user-level Flatpak overrides,
and adds the two global-menu preferences to the first matching Zen profile's
`user.js`. Review the script before running it. Restart Zen after installation
and confirm that `about:support` reports the Wayland window protocol.

## Verify

Check the active overrides:

```sh
flatpak override --user --show app.zen_browser.zen
```

The output should include `MOZ_ENABLE_WAYLAND=1`, the `LD_LIBRARY_PATH` pointing
to the Zen data directory, and permission to talk to
`com.canonical.AppMenu.Registrar`.

To check that the library is loaded in the main Zen process:

```sh
MAIN_PID="$(pgrep -o -f 'app.zen_browser.zen')"
grep dbusmenu "/proc/$MAIN_PID/maps"
```

## Uninstall

```sh
./uninstall.sh
```

The script removes the copied libraries and unsets the Flatpak overrides. It
does not remove preferences previously added to `user.js`; set
`widget.gtk.global-menu.enabled` and
`widget.gtk.global-menu.wayland.enabled` to `false` manually if you want to
disable them. Restart Zen after uninstalling.

## Limitations

This is a local workaround, not a change to Zen or Flathub. A Zen update may
change its Flatpak runtime or internal menu implementation. The workaround may
then need to be reviewed or removed.
