#!/bin/zsh
# Builds "Puckless.app", installs it to ~/Applications and starts it.
set -euo pipefail
cd "${0:A:h}/.."

NAME="Puckless"
BUILD=build
APP="$BUILD/$NAME.app"
TARGET="$HOME/Applications/$NAME.app"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/de.lproj"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key><string>local.puckless.app</string>
  <key>CFBundleName</key><string>Puckless</string>
  <key>CFBundleExecutable</key><string>Puckless</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.2</string>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleLocalizations</key>
  <array><string>en</string><string>de</string></array>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
  <key>NSBluetoothAlwaysUsageDescription</key>
  <string>Puckless controls your speaker over Bluetooth.</string>
</dict>
</plist>
PLIST

# macOS shows this prompt in the system language, independent of the app's language setting.
cat > "$APP/Contents/Resources/de.lproj/InfoPlist.strings" <<'STRINGS'
"NSBluetoothAlwaysUsageDescription" = "Puckless steuert deinen Lautsprecher per Bluetooth.";
STRINGS

# Icon
ICONWORK="$BUILD/icon"
rm -rf "$ICONWORK"
mkdir -p "$ICONWORK/AppIcon.iconset"
swiftc -O -parse-as-library scripts/make_icon.swift Sources/DialIcon.swift -o "$ICONWORK/make_icon"
"$ICONWORK/make_icon" "$ICONWORK/icon.png"
for s in 16 32 128 256 512; do
  sips -z $s $s "$ICONWORK/icon.png" --out "$ICONWORK/AppIcon.iconset/icon_${s}x${s}.png" >/dev/null
  d=$((s * 2))
  sips -z $d $d "$ICONWORK/icon.png" --out "$ICONWORK/AppIcon.iconset/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$ICONWORK/AppIcon.iconset" -o "$APP/Contents/Resources/AppIcon.icns"

# App
swiftc -O -parse-as-library Sources/*.swift -target arm64-apple-macos13.0 \
  -framework CoreBluetooth -framework SwiftUI -framework AppKit \
  -framework ServiceManagement -framework Carbon \
  -o "$APP/Contents/MacOS/Puckless"
codesign --force --sign - "$APP"

# Install and start
pkill -x Puckless 2>/dev/null || true
mkdir -p "$HOME/Applications"
rm -rf "$TARGET"
cp -R "$APP" "$TARGET"
open "$TARGET"
echo "Installed and started: $TARGET"
