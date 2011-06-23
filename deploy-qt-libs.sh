#!/bin/sh

echo "usage: deploy <qt-source-dir> <qt-version>"

HOST_LOCATION="$1"
TARGET_LOCATION=/data/local/qt
VERSION="$2"

ADB="$ANDROID_SDK_ROOT"/platform-tools/adb
STRIP="$ANDROID_NDK_ROOT"/toolchains/"$ANDROID_NDK_TOOLCHAIN_PREFIX"-"$ANDROID_NDK_TOOLCHAIN_VERSION"/prebuilt/"$ANDROID_NDK_HOST"/bin/"$ANDROID_NDK_TOOLCHAIN_PREFIX"-strip

echo "# Waiting for device"
    $ADB wait-for-device

echo "# Removing $TARGET_LOCATION device"
$ADB shell rm -r "$TARGET_LOCATION" || exit 0

echo "# Pushing libs to device"
for i in $( ls "$HOST_LOCATION"/lib/*.so."$VERSION" ); do
	echo "# Stripping symbols from $i"
	$STRIP --strip-unneeded "$i"
	echo "# Pushing $i $TARGET_LOCATION/lib"
	$ADB push "$i" "$TARGET_LOCATION"/lib
done

### FIXME: we should strip these too

echo "# Pushing imports to device"
$ADB push "$HOST_LOCATION"/imports "$TARGET_LOCATION"/imports

echo "# Pushing plugins to device"
$ADB push "$HOST_LOCATION"/plugins "$TARGET_LOCATION"/plugins