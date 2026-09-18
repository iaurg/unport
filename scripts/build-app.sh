#!/bin/bash
# Builds a release binary and wraps it in a minimal Unport.app bundle.
set -euo pipefail

cd "$(dirname "$0")/.."

APP="build/Unport.app"
VERSION="${VERSION:-0.0.0-dev}"
# Homebrew builds inside its own sandbox and passes SWIFT_BUILD_FLAGS=--disable-sandbox.
read -r -a BUILD_FLAGS <<< "-c release ${SWIFT_BUILD_FLAGS:-}"

swift build "${BUILD_FLAGS[@]}"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
BIN="$(swift build "${BUILD_FLAGS[@]}" --show-bin-path)"
cp "$BIN/Unport" "$APP/Contents/MacOS/Unport"

"$BIN/IconGenerator" build/AppIcon.iconset
iconutil -c icns build/AppIcon.iconset -o "$APP/Contents/Resources/AppIcon.icns"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Unport</string>
    <key>CFBundleIdentifier</key>
    <string>io.github.iaurg.unport</string>
    <key>CFBundleExecutable</key>
    <string>Unport</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST

# Ad-hoc signature: enough to run locally without Gatekeeper complaining about a broken bundle.
codesign --force --sign - "$APP"

echo "Built $APP"
