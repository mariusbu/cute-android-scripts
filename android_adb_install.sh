#!/bin/sh
PROJECT="$PWD"
FILE="$PROJECT/bin/$1.apk"
NAME="$(echo $1 | tr '[:upper:]' '[:lower:]')"
PACKAGE="com.cutehacks.$NAME"
ANDROID_SDK="/Users/mariusbu/Development/Android/android-sdk-mac_x86"

echo "# Waiting for device"
$ANDROID_SDK/platform-tools/adb wait-for-device

echo "# Uninstalling $PACKAGE"
$ANDROID_SDK/platform-tools/adb uninstall "$PACKAGE"

echo "# Installing $FILE"
$ANDROID_SDK/platform-tools/adb install "$FILE"
