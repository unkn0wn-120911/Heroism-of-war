#!/usr/bin/env bash
export ANDROID_HOME="/opt/android-sdk"
export ANDROID_SDK_ROOT="/opt/android-sdk"
export ANDROID_NDK_ROOT="/opt/android-sdk/ndk/26.3.11579264"
export PATH="/home/codespace/bin:/opt/android-sdk/platform-tools:/opt/android-sdk/cmdline-tools/latest/bin:$PATH"
export GODOT_BIN="/opt/godot/Godot_v4.7.2-stable_linux.x86_64"

if [ -x "$GODOT_BIN" ]; then
  echo "Godot 4 is ready: $GODOT_BIN"
else
  echo "Godot binary not found at $GODOT_BIN"
fi

if [ -d "$ANDROID_SDK_ROOT" ]; then
  echo "Android SDK ready at $ANDROID_SDK_ROOT"
fi
