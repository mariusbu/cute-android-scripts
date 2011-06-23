#!/bin/sh

echo "usage: create-project <name>

mkdir "$1"
$ANDROID_SDK_ROOT/tools/android create project \
--target "$ANDROID_PLATFORM \
--name "$1" \
--path "./$1" \
--activity "$1" \
--package "$ANDROID_PACKAGE_NAMESPACE$1"
