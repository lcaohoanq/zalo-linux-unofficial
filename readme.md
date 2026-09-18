# Zalo for Linux (Unofficial Port)

This project is an unofficial Linux port of the Zalo macOS desktop client. It
runs the extracted desktop application with Electron; it is not a wrapper for
the Zalo website.

## Requirements

- Linux x86_64
- `unzip`, `sha256sum`, and `awk`
- Either `curl` or `wget`

The installer is user-local and does not use `sudo` or install system packages.

## Install

```bash
git clone https://github.com/ducseul/zalo-linux-unofficial.git
cd zalo-linux-unofficial
./install.sh
```

Zalo is installed under `${XDG_DATA_HOME:-$HOME/.local/share}/Zalo` and can be
started from the desktop application menu. Closing its main window keeps it
available from the native system tray.

## Uninstall

```bash
"${XDG_DATA_HOME:-$HOME/.local/share}/Zalo/uninstall.sh"
```

Uninstalling removes the application files and desktop entry but preserves Zalo
account and message data.

## Credit

Inspired by [realdtn2/zalo-linux-unofficial-2024](https://github.com/realdtn2/zalo-linux-unofficial-2024).
