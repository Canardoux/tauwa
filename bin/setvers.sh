#!/bin/bash
if [ -z "$1" ]; then
        echo "Correct usage is $0 <Version>"
        exit -1
fi



VERSION=$1
VERSION_CODE=${VERSION//./}
VERSION_CODE=${VERSION_CODE//+/}

# Flutter - Tau
# -------------
gsed -i  "s/^\( *version: *\).*$/\1$VERSION/"                                           pubspec.yaml
gsed -i  "s/^\( *tau_plugin: *#* *\^*\).*$/\1$VERSION/"                                 pubspec.yaml

gsed -i  "s/^\( *version: *\).*$/\1$VERSION/"                                           example/pubspec.yaml
gsed -i  "s/^\( *tau: *#* *\^*\).*$/\1$VERSION/"                                        example/pubspec.yaml
gsed -i  "s/^\( *tau_plugin: *#* *\^*\).*$/\1$VERSION/"                                 example/pubspec.yaml

gsed -i  "s/^\( *version: *\).*$/\1$VERSION/"                                           tau_plugin/pubspec.yaml
gsed -i  "s/^\( *version: *\).*$/\1$VERSION/"                                           tau_plugin/example/pubspec.yaml
gsed -i  "s/^\( *tau_plugin: *#* *\^*\).*$/\1$VERSION/"                                 tau_plugin/example/pubspec.yaml

gsed -i  "s/^\( *s.version *= *\).*$/\1'$VERSION'/"                                     ios/tau.podspec 2>/dev/null

gsed -i  "s/^\( *version *\).*$/\1'$VERSION'/"                                          android/build.gradle

gsed -i  "s/^\( *## \).*$/\1$VERSION/"                                                  CHANGELOG.md
gsed -i  "s/^\( *## \).*$/\1$VERSION/"                                                  tau_plugin/CHANGELOG.md

gsed -i  "s/^TAU_VERSION:.*/TAU_VERSION: $VERSION/"                                     doc/_config.yml
gsed -i  "s/^\( *version: \).*/\1$VERSION/"                                             doc/_data/sidebars/mydoc_sidebar.yml

# gsed -i  "s/^\( *flutter_sound_web: *#* *\).*$/\1$VERSION/"                           flutter_sound/pubspec.yaml
# gsed -i  "s/^\( *flauto_web: *#* *\).*$/\1$VERSION/"                                  flutter_sound/pubspec.yaml
# gsed -i  "s/^\( *#* *flutter_sound_web: *#* *\^*\).*$/\1$VERSION/"                    flutter_sound/example/pubspec.yaml
# gsed -i  "s/^\( *#* *flauto_web: *#* *\^*\).*$/\1$VERSION/"                           flutter_sound/example/pubspec.yaml
# gsed -i  "s/const VERSION = .*$/const VERSION = '$VERSION'/"                          flutter_sound_web/src/flutter_sound.js;
# gsed -i  "s/const PLAYER_VERSION = .*$/const PLAYER_VERSION = '$VERSION'/"            flutter_sound_web/src/flutter_sound_player.js;
# gsed -i  "s/const RECORDER_VERSION = .*$/const RECORDER_VERSION = '$VERSION'/"        flutter_sound_web/src/flutter_sound_recorder.js;
# gsed -i  "s/^\( *version: *\).*$/\1$VERSION/"                                         flutter_sound_web/pubspec.yaml
# gsed -i  "s/^\( *flutter_sound_platform_interface: *#* *\).*$/\1$VERSION/"            flutter_sound_web/pubspec.yaml
# gsed -i  "s/^\( *flauto_platform_interface2: *#* *\).*$/\1$VERSION/"                  flutter_sound_web/pubspec.yaml
# gsed -i  "s/^\( *## \).*$/\1$VERSION/"                                                flutter_sound_web/CHANGELOG.md
# gsed -i  "s/^\( *\"version\": *\).*$/\1\"$VERSION\",/"                                flutter_sound_web/package.json

exit 0

# ----------------------------------------------------------------------------------------

