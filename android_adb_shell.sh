#!/bin/sh
ANDROID_SDK="/Users/mariusbu/Development/Android/android-sdk-mac_x86"

echo "# Waiting for device"
$ANDROID_SDK/platform-tools/adb wait-for-device

echo "# Starting shell on device"
$ANDROID_SDK/platform-tools/adb shell 
