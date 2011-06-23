#!/bin/sh

echo "usage: create-qt-project <project-name> <qt-source-dir>"

PROJECT_NAME="$1"
HOST_LOCATION="$2"

if [ -z "$PROJECT_NAME" ] | [ -z "$HOST_LOCATION" ]; then
	exit 1
fi

PACKAGE_NAME="$ANDROID_PACKAGE_NAMESPACE"."$PROJECT_NAME"
PACKAGE_PATH=$(echo $PACKAGE_NAME | tr '.' '/')

# Create the android project

$ANDROID_SDK_ROOT/tools/android create project \
--name $PROJECT_NAME \
--target $ANDROID_PLATFORM \
--path $PROJECT_NAME-java	\
--activity QtMain \
--package $PACKAGE_NAME

if [ "$?" -ne 0 ]; then
	echo "Failed to create android project"
	exit \$?
fi

TARGET_LOCATION=$PROJECT_NAME-java/src/$PACKAGE_PATH
TEMPLATE_PATH=$HOST_LOCATION/examples/android/QtAnimatedtiles/src/org/animatedtiles
TEMPLATE_NAME=animatedtiles

rm $TARGET_LOCATION/QtMain.java
mkdir -p $TARGET_LOCATION/qt
cp $TEMPLATE_PATH/qt/QtMain.java $TARGET_LOCATION/qt/QtMain.java
cp $TEMPLATE_PATH/AndroidManifest.xml $TARGET_LOCATION/AndroidManifest.xml
sed -i "s/$TEMPLATE_NAME/$PROJECT_NAME/g" $TARGET_LOCATION/qt/QtMain.java
sed -i "s/$TEMPLATE_NAME/$PROJECT_NAME/g" $TARGET_LOCATION/AndroidManifest.xml

# Create the Qt project

mkdir $PROJECT_NAME-cpp

cat > $PROJECT_NAME-cpp/main.cpp <<EOF
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

cat > $PROJECT_NAME-cpp/$PROJECT_NAME.pro <<EOF
QT += core gui
TARGET = $PROJECT_NAME
SOURCES = main.cpp
EOF

# Make package build scripts

cat > make-apk.sh <<EOF
#!/bin/sh
# move the libs over
mkdir -p $PROJECT_NAME-java/libs/armeabi
cp $PROJECT_NAME-cpp/lib$PROJECT_NAME.so* $PROJECT_NAME/libs/armeabia
# make the package
cd $PROJECT_NAME
ant debug
if [\$? -ne 0 ]; then
	echo "Faild to build package"
	exit \$?
fi

exit 0
EOF

chmod +x make-apk.sh

# Make run script
cat > adb-start.sh <<EOF
#!/bin/sh
\$ANDROID_SDK_ROOT/tools/adb shell am start -n $PACKAGE_NAME.qt/.QtMain
exit 0
EOF

chmod +x adb-start.sh
