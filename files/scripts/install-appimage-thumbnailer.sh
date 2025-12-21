#!/bin/sh

set -eu

if [ "$OS_ARCH" = "x86_64" ]; then
  release_assets=$(curl -fLsS --retry 5 -H 'Accept: application/vnd.github+json' \
  https://api.github.com/repos/kem-a/appimage-thumbnailer/releases/latest \
  | jq -cr '.assets | map({(.name | tostring): .browser_download_url}) | add')
  rpm_url=$(echo "$release_assets" | jq -cr '.[keys_unsorted[] | select(test("appimage-thumbnailer.*x86_64\\.rpm$"))]')
  curl -fLsS --retry 5 -o "/tmp/appimage-thumbnailer.rpm" "$rpm_url"
  dnf -y install "/tmp/appimage-thumbnailer.rpm" 7zip glib2 gdk-pixbuf2 librsvg2 cairo
else
  echo "AppImage thumbnailer is not available for 'aarch64' and other architectures yet"
fi
