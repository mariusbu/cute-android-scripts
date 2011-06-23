#!/bin/sh

echo "usage: adb-install <path-to-project> <package-name>

PROJECT="$1"
FILE="$PROJECT/bin/$2.apk"
NAME="$(echo $2 | tr '[:upper:]' '[:lower:]')"
PACKAGE="$ANDROID_PACKAGE_NAMESPACE.$NAME"

echo "# Waiting for device"
$ANDROID_SDK_ROOT/platform-tools/adb wait-for-device

echo "# Uninstalling $PACKAGE"
$ANDROID_SDK_ROOT/platform-tools/adb uninstall "$PACKAGE"

echo "# Installing $FILE"
$ANDROID_SDK_ROOT/platform-tools/adb install "$FILE"
