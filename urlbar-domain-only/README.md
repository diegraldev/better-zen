# Domain-Only URL Bar

This optional AutoConfig module makes Zen display the registrable domain while
the address bar is idle. For example, `https://github.com/user/repository`
appears as `github.com`. Focusing or expanding the URL bar restores the full
address; leaving it restores the shortened display.

## Requirements

- Zen Browser installed as the system Flatpak with application ID
  `app.zen_browser.zen`.
- Administrator authentication to write AutoConfig files into the Flatpak
  application deployment.

## Install

Run the installer from this directory:

```sh
./install.sh
```

Restart Zen after installation. Each Zen Flatpak update creates a new
application deployment, so run the installer again after updating.

## Uninstall

```sh
./uninstall.sh
```

Restart Zen to remove the behavior.

## Implementation and security

Zen calls `gURLBar._zenTrimURL` when formatting the address-bar value. The
module replaces that hook with a function that uses Firefox's effective-TLD
service to find the registrable domain. It preserves internal pages, IP
addresses, and hosts for which no registrable domain is available.

The module uses Firefox AutoConfig and its `Components` APIs. Its loader sets
`general.config.sandbox_enabled` to `false`, as required for this privileged
browser-chrome integration. Review the source before installing. The installer
adds files to Zen's application deployment; it does not modify `omni.ja`.
