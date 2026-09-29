#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
if [[ -d /Applications/Xcode-beta.app/Contents/Developer ]]; then
    export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
fi
swift build -c release
app="$PWD/dist/Otimizador MacTech.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Library/LaunchAgents"
cp .build/release/MacTech "$app/Contents/MacOS/MacTech"
cp Resources/Info.plist "$app/Contents/Info.plist"
cp Resources/com.danilonovais.mactech.login.plist "$app/Contents/Library/LaunchAgents/"
codesign --force --sign "${CODE_SIGN_IDENTITY:--}" --options runtime "$app"
codesign --verify --strict --deep "$app"
printf '%s\n' "$app"
