#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GODOT_VERSION="4.7.2"
GODOT_BIN="${GODOT_BIN:-/opt/godot/Godot_v${GODOT_VERSION}-stable_linux.x86_64}"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-/opt/android-sdk}"
TEMPLATE_ROOT="$HOME/.local/share/godot/export_templates/${GODOT_VERSION}.stable"

mkdir -p "$ROOT/build" "$ROOT/android"

if [ ! -x "$GODOT_BIN" ]; then
  echo "Downloading Godot ${GODOT_VERSION}..."
  mkdir -p /opt/godot
  cd /tmp
  curl -L -o godot-editor.zip "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
  unzip -q -o godot-editor.zip -d /opt/godot
  chmod +x "$GODOT_BIN"
fi

if [ ! -f "$TEMPLATE_ROOT/android_debug.apk" ]; then
  echo "Downloading Godot export templates..."
  mkdir -p "$TEMPLATE_ROOT"
  cd /tmp
  curl -L -o export_templates.tpz "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_export_templates.tpz"
  unzip -q -o export_templates.tpz -d "$TEMPLATE_ROOT"
  ln -sf "$TEMPLATE_ROOT/templates/android_debug.apk" "$TEMPLATE_ROOT/android_debug.apk"
  ln -sf "$TEMPLATE_ROOT/templates/android_release.apk" "$TEMPLATE_ROOT/android_release.apk"
  ln -sf "$TEMPLATE_ROOT/templates/android_source.zip" "$TEMPLATE_ROOT/android_source.zip"
fi

if [ ! -f "$ROOT/android/debug.keystore" ]; then
  echo "Generating debug keystore..."
  keytool -genkey -v \
    -keystore "$ROOT/android/debug.keystore" \
    -alias androiddebugkey \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass android \
    -keypass android \
    -dname "CN=Heroism of War, OU=GameDev, O=Heroism of War, L=Remote, S=NA, C=US"
fi

export ANDROID_HOME="$ANDROID_SDK_ROOT"
export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/cmdline-tools/bin:$PATH"

"$GODOT_BIN" --headless --path "$ROOT" --export-debug "Android" "$ROOT/build/HeroismOfWar-debug.apk"

echo "APK created at: $ROOT/build/HeroismOfWar-debug.apk"
