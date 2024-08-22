#!/bin/bash
if [ -z "$1" ]; then
        echo "Correct usage is $0 <Version> "
        exit -1
fi



VERSION=$1
VERSION_CODE=${VERSION#./}
VERSION_CODE=${VERSION_CODE#+/}

bin/setvers.sh $VERSION
bin/gen.sh
# DEV mode to be able to do analyze
bin/reldev.sh DEV

rm -rf _*.tgz
#!!! rm all the .sav

flutter analyze lib
if [ $? -ne 0 ]; then
    echo "Error: analyze tau/lib"
    exit -1
fi

dart format lib
if [ $? -ne 0 ]; then
    echo "Error: format tau/lib"
    exit -1
fi

bin/dart-doc.sh
if [ $? -ne 0 ]; then
    echo "Error: dart doc"
    exit -1
fi


flutter analyze example/lib
if [ $? -ne 0 ]; then
    echo "Error: analyze example/lib"
    exit -1
fi

dart format  example/lib
if [ $? -ne 0 ]; then
    echo "Error: format example/lib"
    exit -1
fi

flutter analyze tau_plugin/lib
if [ $? -ne 0 ]; then
    echo "Error: analyze tau_plugin/lib"
    exit -1
fi

dart format  tau_plugin/lib
if [ $? -ne 0 ]; then
    echo "Error: format tau_plugin/lib"
    exit -1
fi

bin/reldev.sh REL

cd tau_plugin
flutter pub publish
if [ $? -ne 0 ]; then
    echo "Error: flutter pub publish[flutter_sound_platform_interface]"
    #!!!!!exit -1
fi
cd ..


flutter pub publish
if [ $? -ne 0 ]; then
    echo "Error: flutter pub publish[flutter_sound_platform_interface]"
    #!!!!!exit -1
fi

exit 0

#dart doc lib
#if [ $? -ne 0 ]; then
#    echo "Error: dart doc tau/lib"
#   #!!!!!exit -1
#fi

flutter clean
flutter pub get

cd example
flutter clean
flutter pub get

flutter analyze lib
if [ $? -ne 0 ]; then
    echo "Error: analyze tau/example/lib"
    exit -1
fi
cd ios
pod cache clean --all
rm Podfile.lock
rm -rf .symlinks/
pod update
pod repo update
pod install --repo-update
pod update
pod install
cd ..

flutter build ios
if [ $? -ne 0 ]; then
    echo "Error: flutter build tau/example/ios"
    exit -1
fi

flutter build apk
if [ $? -ne 0 ]; then
    echo "Error: flutter build tau/example/android"
    exit -1
fi

flutter build web
if [ $? -ne 0 ]; then
    echo "Error: flutter build tau/example/android"
    exit -1
fi

cd ..

bin/doc.sh $VERSION

flutter pub publish
if [ $? -ne 0 ]; then
    echo "Error: flutter pub publish[tau]"
    # We do not exit to ignore when the Tau Version is already published
    #!!!!!!exit -1
fi


# Bug in flutter tools : if "flutter build --release" we must first "--debug" and then "--profile" before "--release"
#flutter build apk --release
#if [ $? -ne 0 ]; then
#    echo "Error: flutter build flutter_sound/example/apk"
#    exit -1
#fi


git add .
git commit -m "TAU : Version $VERSION"
git pull origin
git push origin
if [ ! -z "$VERSION" ]; then
        git tag -f $VERSION
        git push  -f origin $VERSION
fi


echo 'E.O.J'
