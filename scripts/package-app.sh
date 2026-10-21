#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_CONFIGURATION="${1:-release}"
APP_DIR="$ROOT_DIR/dist/KeepCat.app"

swift build \
  --package-path "$ROOT_DIR" \
  --configuration "$BUILD_CONFIGURATION"

BUILD_DIR="$(
  swift build \
    --package-path "$ROOT_DIR" \
    --configuration "$BUILD_CONFIGURATION" \
    --show-bin-path
)"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp "$BUILD_DIR/KeepCat" "$APP_DIR/Contents/MacOS/KeepCat"

RESOURCE_BUNDLE="$(find "$BUILD_DIR" -maxdepth 1 -name 'KeepCat_KeepCat.bundle' -print -quit)"
if [[ -n "$RESOURCE_BUNDLE" ]]; then
  cp -R "$RESOURCE_BUNDLE" "$APP_DIR/Contents/Resources/"
fi

plutil -create xml1 "$APP_DIR/Contents/Info.plist"
plutil -insert CFBundleDevelopmentRegion -string zh-Hans "$APP_DIR/Contents/Info.plist"
plutil -insert CFBundleDisplayName -string KeepCat "$APP_DIR/Contents/Info.plist"
plutil -insert CFBundleExecutable -string KeepCat "$APP_DIR/Contents/Info.plist"
plutil -insert CFBundleIdentifier -string com.keepcat.app "$APP_DIR/Contents/Info.plist"
plutil -insert CFBundleInfoDictionaryVersion -string 6.0 "$APP_DIR/Contents/Info.plist"
plutil -insert CFBundleName -string KeepCat "$APP_DIR/Contents/Info.plist"
plutil -insert CFBundlePackageType -string APPL "$APP_DIR/Contents/Info.plist"
plutil -insert CFBundleShortVersionString -string 0.1.0 "$APP_DIR/Contents/Info.plist"
plutil -insert CFBundleVersion -string 1 "$APP_DIR/Contents/Info.plist"
plutil -insert LSMinimumSystemVersion -string 14.0 "$APP_DIR/Contents/Info.plist"
plutil -insert LSUIElement -bool true "$APP_DIR/Contents/Info.plist"
plutil -insert LSMultipleInstancesProhibited -bool true "$APP_DIR/Contents/Info.plist"
plutil -insert NSHighResolutionCapable -bool true "$APP_DIR/Contents/Info.plist"

codesign --force --deep --sign - "$APP_DIR"

printf 'Created %s\n' "$APP_DIR"
