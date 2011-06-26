#!/bin/sh

echo "usage: create-qt-project <project-name> <qt-source-dir>"

PROJECT_NAME="$1"
HOST_LOCATION="$2"
PROJECT_DIR=$PWD/$PROJECT_NAME

if [ -z "$PROJECT_NAME" ] | [ -z "$HOST_LOCATION" ]; then
	exit 1
fi

echo "#### project: $PROJECT_DIR qt: $HOST_LOCATION"

PACKAGE_NAME="$ANDROID_PACKAGE_NAMESPACE"."$PROJECT_NAME"
PACKAGE_PATH=$(echo $PACKAGE_NAME | tr '.' '/')

# Create project dir and copy qt android files

ANDROID_DIR_NAME="android"
ANDROID_MANIFEST_NAME="AndroidManifest.xml"
ANDROID_LIBS_FILE_NAME="/res/values/libs.xml"
ANDROID_STRINGS_FILE_NAME="/res/values/strings.xml"
ANDROID_DEFAULT_PROPERTIES_NAME="default.properties"
ANDROID_ABI_NAME=armeabi

ANDROID_DIR_PATH=$PROJECT_DIR/$ANDROID_DIR_NAME

TEMPLATE_LOCATION=$HOST_LOCATION/src/android/java
TEMPLATE_NAMESPACE=eu.licentia.necessitas.industrius
TEMPLATE_NAME=example
TEMPLATE_PACKAGE="$TEMPLATE_NAMESPACE.$TEMPLATE_NAME"

mkdir -p $PROJECT_DIR/$ANDROID_DIR_NAME/src
mkdir -p $PROJECT_DIR/$ANDROID_DIR_NAME/libs/$ANDROID_ABI_NAME

for i in $( ls "$TEMPLATE_LOCATION" ); do
	cp -r $TEMPLATE_LOCATION/$i $ANDROID_DIR_PATH/
done

# Patch the manifest file

sed -i .old "s/$TEMPLATE_PACKAGE/$PACKAGE_NAME/g" $ANDROID_DIR_PATH/$ANDROID_MANIFEST_NAME
sed -i .old "s/\"\"/\"$PROJECT_NAME\"/g" $ANDROID_DIR_PATH/$ANDROID_MANIFEST_NAME
sed -i .old "s/></>$PROJECT_NAME</g" $ANDROID_DIR_PATH/$ANDROID_STRINGS_FILE_NAME

# Generate files for the android build system

cat > $ANDROID_DIR_PATH/local.properties <<EOF
sdk.dir=$ANDROID_SDK_ROOT
EOF

cat > $ANDROID_DIR_PATH/default.properties <<EOF
target=$ANDROID_NDK_PLATFORM
EOF

cat > $ANDROID_DIR_PATH/build.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<project name="$PROJECT_NAME" default="help">
	<property file="local.properties" />
	<property file="build.properties" />
	<property file="default.properties" />
	<import file="\${sdk.dir}/tools/ant/pre_setup.xml" />
	<setup />
</project>
EOF

cat > $ANDROID_DIR_PATH/proguard.cfg <<EOF
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*

-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference
-keep public class com.android.vending.licensing.ILicensingService

-keepclasseswithmembernames class * {
    native <methods>;
}

-keepclasseswithmembernames class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

-keepclasseswithmembernames class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

-keepclassmembers enum * {
	public static **[] values();
	public static ** valueOf(java.lang.String);
}

-keep class * implements android.os.Parcelable {
	public static final android.os.Parcelable\$Creator *;
}
EOF

# Create the Qt project

cat > $PROJECT_DIR/main.cpp <<EOF
#include <QtGui/QApplication>
#include <QtGui/QWidget>

int main(int argc, char *argv[])
{
	QApplication app(argc, argv);
	QWidget widget;
	widget.show();
	return app.exec();
}
EOF

cat > $PROJECT_DIR/$PROJECT_NAME.pro <<EOF
QT += core gui
DESTDIR = $ANDROID_DIR_NAME/libs/$ANDROID_ABI_NAME/
TARGET = $PROJECT_NAME
SOURCES = main.cpp
EOF

# Create script for updating Qt

cat > $PROJECT_DIR/update_qt.sh <<EOF
#!/bin/sh
rm $ANDROID_DIR_NAME/libs/$ANDROID_ABI_NAME/libQt*
cp $HOST_LOCATION/lib/libQt*.so $ANDROID_DIR_NAME/libs/$ANDROID_ABI_NAME/
\$ANDROID_NDK_ROOT/toolchains/\$ANDROID_NDK_TOOLCHAIN_PREFIX-\$ANDROID_NDK_TOOLCHAIN_VERSION/prebuilt/\$ANDROID_NDK_HOST/bin/\$ANDROID_NDK_TOOLCHAIN_PREFIX-strip --strip-unneeded $ANDROID_DIR_NAME/libs/$ANDROID_ABI_NAME/*
EOF
chmod +x $PROJECT_DIR/update_qt.sh
