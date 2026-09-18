#!/usr/bin/env bash

set -Eeuo pipefail

APP_NAME="Zalo"
INSTALL_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DATA_HOME="$(dirname -- "$INSTALL_DIR")"
APPLICATIONS_DIR="$DATA_HOME/applications"
DESKTOP_FILE="$APPLICATIONS_DIR/$APP_NAME.desktop"

if [[ "$(basename -- "$INSTALL_DIR")" != "$APP_NAME" ]]; then
    echo "Error: refusing to remove unexpected install directory: $INSTALL_DIR" >&2
    exit 1
fi

rm -f -- "$DESKTOP_FILE"
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APPLICATIONS_DIR" >/dev/null 2>&1 || true
fi

rm -rf -- "$INSTALL_DIR"
echo "$APP_NAME uninstalled successfully. User data was preserved."
