#!/bin/sh

echo "usage: resize-partition <device> <size>

DEVICE_NAME=%1
PARTITION_SIZE=%2

$ANDROID_SDK_ROOT/tools/emulator -avd "$DEVICE_NAME" -partition-size "$PARTITION_SIZE" -no-snapshot-load