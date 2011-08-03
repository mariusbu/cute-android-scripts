#!/bin/sh

if [ -z $2 ]; then
	echo "usage: deploy <qt-source-dir> <qt-version>"
	exit 0
fi

HOST_LOCATION="$1"
TEMP_LOCATION=/tmp/repath
TARGET_LOCATION=/data/local/qt
VERSION="$2"

REPATH=repath/repath
ADB="$ANDROID_SDK_ROOT"/platform-tools/adb
STRIP="$ANDROID_NDK_ROOT"/toolchains/"$ANDROID_NDK_TOOLCHAIN_PREFIX"-"$ANDROID_NDK_TOOLCHAIN_VERSION"/prebuilt/"$ANDROID_NDK_HOST"/bin/"$ANDROID_NDK_TOOLCHAIN_PREFIX"-strip

traverse()
{
	ls "$1" | while read i
	do
		if [ -d "$1/$i" ]; then
			traverse "$1/$i"
		else
			extension=`echo "$1/$i" | cut -f2 -d '.'`
			if [ "$extension" == "so" ]; then
				echo "# Patching and stripping" "$1/$i"
				$STRIP --strip-unneeded "$1/$i"
				$REPATH "$1/$i" "$1/$i" "$HOST_LOCATION" "$TARGET_LOCATION"
			fi
		fi
	done
}

echo "# Copying libs, imports and plugins to a temporary location"
rm -r "$TEMP_LOCATION"
mkdir -p "$TEMP_LOCATION/lib"
mkdir -p "$TEMP_LOCATION/imports"
mkdir -p "$TEMP_LOCATION/plugins"
cp "$HOST_LOCATION"/lib/*.so."$VERSION" "$TEMP_LOCATION/lib/"
cp -R "$HOST_LOCATION/imports" "$TEMP_LOCATION/"
cp -R "$HOST_LOCATION/plugins" "$TEMP_LOCATION/"

echo "# Patching paths and stripping libs, imports and plugins"
traverse "$TEMP_LOCATION"

echo "# Waiting for device"
$ADB wait-for-device

echo "# Removing $TARGET_LOCATION device"
$ADB shell rm -r "$TARGET_LOCATION" || exit 0

echo "# Pushing libs, imports and plugins to the device"
$ADB push "$TEMP_LOCATION/lib" "$TARGET_LOCATION/lib"
$ADB push "$TEMP_LOCATION/imports" "$TARGET_LOCATION/imports"
$ADB push "$TEMP_LOCATION/plugins" "$TARGET_LOCATION/plugins"