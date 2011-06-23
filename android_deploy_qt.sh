#!/bin/sh

echo "usage: deploy <qt-source-dir> <qt-version>"

HOST_LOCATION="$1"
TARGET_LOCATION=/data/local
VERSION="$2"

ADB="$ANDROID_SDK_ROOT"/platform-tools/adb

echo "# Waiting for device"
    $ADB wait-for-device

echo "Pushing qt to device"
$ADB shell mkdir "$TARGET_LOCATION"/qt/lib
for i in $( ls "$HOST_LOCATION"/lib/*.so."$VERSION" ); do
	echo "Pushing $i $TARGET_LOCATION/qt/lib"
	$ADB push "$i" "$TARGET_LOKATION"/qt/lib
done

#echo "Pushing platform plugin to device"
#$ADB shell mkdir "$TARGET_LOCATION"/qt/plugins/platforms/android
#$ADB push "$HOST_LOCATION"/plugins/platforms/android "$TARGET_LOCATION"/qt/plugins/platforms/android