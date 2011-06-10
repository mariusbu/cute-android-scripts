#!/bin/sh
DEVICE_NAMME=%1
PARTITION_SIZE=%2
ANDROID_SDK="/Users/mariusbu/Development/Android/android-sdk-mac_x86"
$ANDROID_SDK/tools/emulator -avd AVDLevel8 -partition-size "$PARTITION_SIZE" -no-snapshot-load