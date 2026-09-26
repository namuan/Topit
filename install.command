#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Topit.app"
BUNDLE_ID="com.lihaoyun6.Topit"
DEST_DIR="$HOME/Applications"
DEST_APP="$DEST_DIR/$APP_NAME"
BUILT_APP="$ROOT/build/Build/Products/Release/$APP_NAME"
OPEN_APP=0

if [ "${1:-}" = "--open" ]; then
  OPEN_APP=1
elif [ "$#" -gt 0 ]; then
  echo "Usage: $0 [--open]"
  exit 2
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "Error: 'xcodebuild' not found. Install Xcode and select it with xcode-select."
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Error: No active developer directory found. Select Xcode with xcode-select."
  exit 1
fi

if osascript -e 'if application "Topit" is running then tell application "Topit" to quit' >/dev/null 2>&1; then
  sleep 0.5
fi

echo "Resetting Topit privacy permissions…"
tccutil reset All "$BUNDLE_ID"

if [ -d "$ROOT/build" ]; then
  echo "Removing stale build artifacts…"
  rm -rf "$ROOT/build"
fi

echo "Building Topit (Release)…"
xcodebuild \
  -project "$ROOT/Topit.xcodeproj" \
  -scheme Topit \
  -configuration Release \
  -destination 'platform=macOS' \
  -derivedDataPath "$ROOT/build" \
  CODE_SIGNING_ALLOWED=YES \
  CODE_SIGN_IDENTITY=- \
  CODE_SIGNING_REQUIRED=YES \
  build

if [ ! -d "$BUILT_APP" ]; then
  echo "Error: Build succeeded but app bundle not found at: $BUILT_APP"
  exit 1
fi

echo "Installing to ${DEST_APP}…"
mkdir -p "$DEST_DIR"
rm -rf "$DEST_APP"
ditto "$BUILT_APP" "$DEST_APP"

echo ""
echo "Installed: $DEST_APP"
if [ "$OPEN_APP" -eq 1 ]; then
  open -n "$DEST_APP"
fi
