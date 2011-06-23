#!/bin/sh

#echo "usage: adb-shell"

echo "# Waiting for device"
$ANDROID_SDK_ROOT/platform-tools/adb wait-for-device

echo "# Starting shell on device"
$ANDROID_SDK_ROOT/platform-tools/adb shell 
