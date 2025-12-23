#!/bin/sh

set -eu

github_json=$(curl -fLsS --retry 5 -H 'Accept: application/vnd.github+json' https://api.github.com/repos/kem-a/appimage-thumbnailer/releases/latest)
release_assets=$(echo "$github_json" | jq -cr '.assets | map({(.name | tostring): .browser_download_url}) | add')
rpm_url=$(echo "$release_assets" | jq -cr --arg arch "$OS_ARCH" '.[keys_unsorted[] | select(test("appimage-thumbnailer.*" + $arch + "\\.rpm$"))]')
if [ -z "$rpm_url" ] || [ "$rpm_url" = "null" ]; then
  echo "AppImage thumbnailer is not available for $OS_ARCH architecture yet"
  exit 0
fi
curl -fLsS --retry 5 -o "/tmp/appimage-thumbnailer.rpm" "$rpm_url"
if [ "$OS_VERSION" -lt 43 ]; then
  dnf -y install p7zip
else
  dnf -y install 7zip
fi
dnf -y install "/tmp/appimage-thumbnailer.rpm" glib2 gdk-pixbuf2 librsvg2 cairo
rm -f "/tmp/appimage-thumbnailer.rpm"
