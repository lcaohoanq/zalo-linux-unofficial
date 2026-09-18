# Zalo for Linux (Unofficial Port)

This project is an unofficial Linux port of the Zalo macOS desktop client. It
runs the extracted desktop application with Electron; it is not a wrapper for
the Zalo website.

## Download a package

Prebuilt packages are available from the [GitHub Releases](https://github.com/lcaohoanq/zalo-linux-unofficial/releases)
page for Linux x86_64. They are currently unsigned, so verify the downloaded
files against the release's `SHA256SUMS` before running or installing them:

```bash
sha256sum --check SHA256SUMS
```

Run the AppImage without installing it:

```bash
chmod +x Zalo-*-linux-x64.AppImage
./Zalo-*-linux-x64.AppImage
```

Or install the DEB package and its system dependencies:

```bash
sudo apt install ./Zalo-*-linux-x64.deb
```

Do not keep both a packaged installation and the user-local installation below;
doing so can create duplicate desktop menu entries.

## Install from source

### Requirements

- Linux x86_64
- `unzip`, `sha256sum`, and `awk`
- Either `curl` or `wget`

The installer is user-local and does not use `sudo` or install system packages.

### Install

```bash
git clone https://github.com/lcaohoanq/zalo-linux-unofficial.git
cd zalo-linux-unofficial
./install.sh
```

Zalo is installed under `${XDG_DATA_HOME:-$HOME/.local/share}/Zalo` and can be
started from the desktop application menu. Closing its main window keeps it
available from the native system tray.

### Uninstall

```bash
"${XDG_DATA_HOME:-$HOME/.local/share}/Zalo/uninstall.sh"
```

Uninstalling removes the application files and desktop entry but preserves Zalo
account and message data.

## Build packages

Node.js 24 is required. The package versions in `package.json`,
`app/package.json`, and `version` must match.

```bash
npm ci
npm run check:version
npm run dist:linux
```

The AppImage and DEB are written to `dist/`. Pull requests, pushes to `main`,
and manual workflow runs also publish the files as the `zalo-linux-x64` Actions
artifact for 14 days.

## Release

1. Update the version in `package.json`, `app/package.json`, and `version`.
2. Merge the version change into `main`.
3. Create and push a `v<version>` tag from that commit.

The tag workflow creates or updates the matching GitHub Release and attaches the
AppImage, DEB, and `SHA256SUMS` file.

## Credit

Inspired by [realdtn2/zalo-linux-unofficial-2024](https://github.com/realdtn2/zalo-linux-unofficial-2024).
