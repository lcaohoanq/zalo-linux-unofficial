#!/usr/bin/env bash

set -Eeuo pipefail

DIST_DIR="${1:-dist}"
shopt -s nullglob

appimages=("$DIST_DIR"/*.AppImage)
debs=("$DIST_DIR"/*.deb)

if (( ${#appimages[@]} != 1 )); then
    echo "Expected exactly one AppImage in $DIST_DIR; found ${#appimages[@]}." >&2
    exit 1
fi
if (( ${#debs[@]} != 1 )); then
    echo "Expected exactly one DEB in $DIST_DIR; found ${#debs[@]}." >&2
    exit 1
fi

(
    cd -- "$DIST_DIR"
    sha256sum --check SHA256SUMS
)

extract_dir="$(mktemp -d "${TMPDIR:-/tmp}/zalo-appimage.XXXXXX")"
deb_contents="$(mktemp "${TMPDIR:-/tmp}/zalo-deb-contents.XXXXXX")"
cleanup() {
    rm -rf -- "$extract_dir"
    rm -f -- "$deb_contents"
}
trap cleanup EXIT

(
    cd -- "$extract_dir"
    "${OLDPWD}/${appimages[0]}" --appimage-extract >/dev/null
)
test -x "$extract_dir/squashfs-root/zalo"
test -f "$extract_dir/squashfs-root/Zalo.desktop"

dpkg-deb --info "${debs[0]}" >/dev/null
dpkg-deb --contents "${debs[0]}" > "$deb_contents"
grep -Eq ' \./opt/Zalo/zalo$' "$deb_contents"
grep -Eq ' \./usr/share/applications/Zalo\.desktop$' "$deb_contents"
grep -Eq ' \./usr/share/icons/hicolor/.+/apps/zalo\.png$' "$deb_contents"

echo "Linux package verification passed."
