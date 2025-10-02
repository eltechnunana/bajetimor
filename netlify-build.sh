#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Flutter (channel: ${FLUTTER_CHANNEL:-stable}, version: ${FLUTTER_VERSION:-latest})"
CHANNEL=${FLUTTER_CHANNEL:-stable}
VERSION=${FLUTTER_VERSION:-}
BASE_URL="https://storage.googleapis.com/flutter_infra_release/releases/${CHANNEL}/linux"

if [ -z "$VERSION" ]; then
  # Fetch latest version manifest and pick current stable tag
  # Fallback to manual version if this fails
  VERSION_TAG="$(curl -sL https://storage.googleapis.com/flutter_infra_release/releases/${CHANNEL}/linux/releases_${CHANNEL}.json | sed -n 's/.*"current_release":"\([^"]*\)".*/\1/p')"
VERSION="${VERSION_TAG:-3.35.0}"
fi

ARCHIVE="flutter_linux_${VERSION}-${CHANNEL}.tar.xz"
curl -L "${BASE_URL}/${ARCHIVE}" -o flutter.tar.xz
tar -xf flutter.tar.xz
export PATH="${PWD}/flutter/bin:${PATH}"

echo "==> Flutter version"
flutter --version
flutter config --enable-web
echo "==> Dart version"
dart --version

echo "==> Installing dependencies"
flutter pub get

echo "==> Building Flutter web (release, no service worker)"
flutter build web --release --pwa-strategy=none

echo "==> Ensuring SQLite WASM assets exist in build output"
mkdir -p build/web
if [ -f web/sqlite3.wasm ]; then
  cp -f web/sqlite3.wasm build/web/sqlite3.wasm
fi
if [ -f web/sqflite_sw.js ]; then
  cp -f web/sqflite_sw.js build/web/sqflite_sw.js
fi
if [ -f web/_redirects ]; then
  cp -f web/_redirects build/web/_redirects
fi
if [ -f web/_headers ]; then
  cp -f web/_headers build/web/_headers
fi

echo "==> Build complete. Publish directory: build/web"