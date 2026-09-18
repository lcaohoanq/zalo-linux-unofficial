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

### Native module compatibility

The application bundle was extracted from the macOS client. The Linux port can
start without loading every native module, but the repository currently ships
no Linux ELF `.node` or `.so` binaries. The statuses below describe the
vendored modules in `app/native/nativelibs`, not general Electron support for
the corresponding feature.

| Module API | Feature | Linux x86_64 (glibc) | Linux x86_64 (musl) | Linux arm64 | Behaviour when used on Linux |
| --- | --- | --- | --- | --- | --- |
| `fileUtils()` | Native file utilities | Fallback only | Fallback only | Fallback only | Loads an `{ error: "not support" }` object; no native operations are available. |
| `sqlite3()` | SQLite binding | Unsupported | Unsupported | Unsupported | Throws `MODULE_NOT_FOUND`; only macOS x64 and arm64 N-API v6 binaries are bundled. |
| `dbUtils()` | Native database utilities | Unsupported | Unsupported | Unsupported | The loader falls through to a missing Windows prebuild and throws `MODULE_NOT_FOUND`. |
| `v8Profiles()` | V8 CPU profiling | Unsupported | Unsupported | Unsupported | Attempts to load the bundled macOS binary and fails with `ERR_DLOPEN_FAILED`. |
| `zimage()` | Image thumbnail and resize operations | Fallback only | Fallback only | Fallback only | Returns a rejected promise with error code `-2` (`NOT_SUPPORT`). |
| `zjxl()` | JPEG XL conversion and resize operations | Fallback only | Fallback only | Fallback only | Loads an `{ error: "not support" }` object; the bundled addon and libraries are macOS-only. |
| `zwalker()` | Message-storage file scanning and cleanup | Unsupported | Unsupported | Unsupported | The generated loader recognises Linux targets, but no Linux binary or platform package is bundled, so loading throws `MODULE_NOT_FOUND`. |
| `zfile()` | Fast file metadata, disk info, and folder copy | Partial fallback | Partial fallback | Partial fallback | Loads no-op `stat`, `diskInfo`, and `statFolder` functions; copy and permission APIs are absent. |
| `zcall()` | Native audio/video calls | Unsupported | Unsupported | Unsupported | The binding returns an unsupported marker, then module initialisation throws because `MainApp` is unavailable. |
| `winUtils()` | Windows integration | Unsupported | Unsupported | Unsupported | The exported loader points to a directory that is not included in the bundle. |
| `zaloLogger()` | Application logging | Supported (JavaScript) | Supported (JavaScript) | Supported (JavaScript) | Works without a native binary; included here because it is exposed by the same module registry. |

`Fallback only` means the module can be imported without immediately crashing,
not that its native feature works. `Unsupported` means callers must avoid the
module or catch the load failure. The released AppImage and DEB remain x86_64
only; the arm64 column records module readiness and does not imply that an arm64
package is available.

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
