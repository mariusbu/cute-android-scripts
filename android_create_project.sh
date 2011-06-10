#!/bin/sh
mkdir "$1"
ANDROID_SDK="/Users/mariusbu/Development/Android/android-sdk-mac_x86"
$ANDROID_SDK/tools/android create project \
--target $2 \
--name "$1" \
--path "./$1" \
--activity "$1" \
--package "com.cutehacks.$1"
