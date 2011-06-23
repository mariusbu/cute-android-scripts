#!/bin/sh

echo "usage: adb-push <name> <target-location>"

NAME=%1
TARGET=%2

echo "# Waiting for device"
$ANDROID_SDK_ROOT/platform-tools/adb wait-for-device

echo "# Starting shell on device"
$ANDROID_SDK_ROOT/platform-tools/adb "$NAME" "$TARGET"/"$NAME
