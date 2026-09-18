#!/usr/bin/env bash

set -Eeuo pipefail

APP_NAME="Zalo"
ELECTRON_VERSION="v22.3.27"
SOURCE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
INSTALL_DIR="$DATA_HOME/$APP_NAME"
APPLICATIONS_DIR="$DATA_HOME/applications"
DESKTOP_FILE="$APPLICATIONS_DIR/$APP_NAME.desktop"

TMP_DIR=""
STAGE_DIR=""
BACKUP_DIR=""
DESKTOP_TMP=""
INSTALLED_NEW=0

cleanup() {
    local status=$?

    [[ -z "$DESKTOP_TMP" ]] || rm -f -- "$DESKTOP_TMP"
    [[ -z "$TMP_DIR" ]] || rm -rf -- "$TMP_DIR"
    [[ -z "$STAGE_DIR" ]] || rm -rf -- "$STAGE_DIR"

    if (( status != 0 )); then
        if (( INSTALLED_NEW == 1 )); then
            rm -rf -- "$INSTALL_DIR"
        fi
        if [[ -n "$BACKUP_DIR" && -d "$BACKUP_DIR" ]]; then
            mv -- "$BACKUP_DIR" "$INSTALL_DIR"
        fi
    elif [[ -n "$BACKUP_DIR" ]]; then
        rm -rf -- "$BACKUP_DIR"
    fi

    exit "$status"
}
trap cleanup EXIT

fail() {
    echo "Error: $*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || fail "required command '$1' was not found."
}

download() {
    local url=$1
    local destination=$2

    if command -v curl >/dev/null 2>&1; then
        curl --fail --location --show-error --output "$destination" "$url"
    else
        wget --output-document="$destination" "$url"
    fi
}

desktop_quote() {
    local value=$1
    value=${value//\\/\\\\}
    value=${value//\"/\\\"}
    value=${value//\`/\\\`}
    value=${value//\$/\\\$}
    value=${value//%/%%}
    printf '"%s"' "$value"
}

[[ "$DATA_HOME" == /* ]] || fail "XDG_DATA_HOME must be an absolute path."
[[ "$(uname -s)" == "Linux" ]] || fail "this installer supports Linux only."
case "$(uname -m)" in
    x86_64|amd64) ELECTRON_ARCH="x64" ;;
    *) fail "unsupported architecture '$(uname -m)'; only Linux x86_64 is supported." ;;
esac

require_command unzip
require_command sha256sum
require_command awk
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    fail "install either 'curl' or 'wget' and run the installer again."
fi

mkdir -p -- "$DATA_HOME" "$APPLICATIONS_DIR"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/zalo-installer.XXXXXX")"
STAGE_DIR="$(mktemp -d "$DATA_HOME/.Zalo.install.XXXXXX")"

ELECTRON_ZIP="electron-${ELECTRON_VERSION}-linux-${ELECTRON_ARCH}.zip"
RELEASE_URL="https://github.com/electron/electron/releases/download/${ELECTRON_VERSION}"

echo "Downloading Electron ${ELECTRON_VERSION}..."
download "$RELEASE_URL/$ELECTRON_ZIP" "$TMP_DIR/$ELECTRON_ZIP"
download "$RELEASE_URL/SHASUMS256.txt" "$TMP_DIR/SHASUMS256.txt"

echo "Verifying Electron download..."
awk -v file="$ELECTRON_ZIP" \
    '$2 == file || $2 == "*" file { print; found=1 } END { exit !found }' \
    "$TMP_DIR/SHASUMS256.txt" > "$TMP_DIR/checksum"
(
    cd -- "$TMP_DIR"
    sha256sum --check --status checksum
) || fail "Electron checksum verification failed."

echo "Preparing application files..."
cp -a -- "$SOURCE_DIR/app" "$STAGE_DIR/app"
cp -a -- "$SOURCE_DIR/assets" "$STAGE_DIR/assets"
cp -a -- "$SOURCE_DIR/uninstall.sh" "$STAGE_DIR/uninstall.sh"
cp -a -- "$SOURCE_DIR/version" "$STAGE_DIR/version"
mkdir -p -- "$STAGE_DIR/electron"
unzip -q "$TMP_DIR/$ELECTRON_ZIP" -d "$STAGE_DIR/electron"
chmod +x "$STAGE_DIR/electron/electron" "$STAGE_DIR/uninstall.sh"

if [[ -e "$INSTALL_DIR" ]]; then
    BACKUP_DIR="$(mktemp -d "$DATA_HOME/.Zalo.backup.XXXXXX")"
    rmdir -- "$BACKUP_DIR"
    mv -- "$INSTALL_DIR" "$BACKUP_DIR"
fi
mv -- "$STAGE_DIR" "$INSTALL_DIR"
STAGE_DIR=""
INSTALLED_NEW=1

ELECTRON_EXEC="$(desktop_quote "$INSTALL_DIR/electron/electron")"
APP_ARGUMENT="$(desktop_quote "$INSTALL_DIR/app")"
DESKTOP_TMP="$(mktemp "$APPLICATIONS_DIR/.Zalo.desktop.XXXXXX")"
cat > "$DESKTOP_TMP" <<EOF
[Desktop Entry]
Name=$APP_NAME
Comment=Zalo desktop client for Linux
Exec=$ELECTRON_EXEC $APP_ARGUMENT
TryExec=$INSTALL_DIR/electron/electron
Icon=$INSTALL_DIR/assets/Zalo.png
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
StartupWMClass=Zalo
EOF
chmod 0644 "$DESKTOP_TMP"
mv -- "$DESKTOP_TMP" "$DESKTOP_FILE"
DESKTOP_TMP=""

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APPLICATIONS_DIR" >/dev/null 2>&1 || true
fi

echo "$APP_NAME installed successfully in $INSTALL_DIR"
