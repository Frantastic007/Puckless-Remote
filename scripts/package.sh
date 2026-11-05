#!/bin/zsh
# Packs the built app and its documents into a release ZIP with a SHA-256 checksum.
# Run scripts/build.sh first.
set -euo pipefail
cd "${0:A:h}/.."

APP=build/Puckless.app
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$APP/Contents/Info.plist")
OUT=build/release
FOLDER="Puckless-$VERSION"
ZIP="$FOLDER.zip"

rm -rf "$OUT"
mkdir -p "$OUT/$FOLDER"
ditto "$APP" "$OUT/$FOLDER/Puckless.app"
cp User-Manual.md Disclaimer.md Security-Review.md CHANGELOG.md LICENSE "$OUT/$FOLDER/"

(cd "$OUT" && ditto -c -k --keepParent "$FOLDER" "$ZIP" && shasum -a 256 "$ZIP" > "$ZIP.sha256")
rm -rf "$OUT/$FOLDER"
cat "$OUT/$ZIP.sha256"
