#!/bin/bash


# Podfile sometimes disapeers !???!
#if [ ! -f flutter_sound/example/ios/Podfile ]; then
#    echo "Podfile not found."
#    cp flutter_sound/example/ios/Podfile.keep flutter_sound/example/ios/Podfile
#fi

if [ "_$1" = "_REL" ] ; then
        echo 'REL mode'
        echo '--------'

        gsed -i  "s/^ *tau: *#* *\(.*\)$/  tau: \1/"                                                                    example/pubspec.yaml
        gsed -i  "s/^ *path: \.\.\/ # Tau Dir$/    # path: \.\.\/ # Tau Dir/"                                           example/pubspec.yaml

        gsed -i  "s/^ *tau_plugin: *#* *\(.*\)$/  tau_plugin: \1/"                                                      example/pubspec.yaml
        gsed -i  "s/^ *path: \.\.\/tau_plugin # tau_plugin Dir$/    # path: \.\.\/tau_plugin # tau_plugin Dir/"         example/pubspec.yaml

        gsed -i  "s/^ *tau_plugin: *#* *\(.*\)$/  tau_plugin: \1/"                                                      tau_plugin/example/pubspec.yaml
        gsed -i  "s/^ *path: \.\.\/ # tau_plugin Dir$/    # path: \.\.\/ # tau_plugin Dir/"                             tau_plugin/example/pubspec.yaml

        gsed -i  "s/^ *tau_plugin: *#* *\(.*\)$/  tau_plugin: \1/"                                                      pubspec.yaml
        gsed -i  "s/^ *path: tau_plugin # tau_plugin Dir$/    # path: tau_plugin # tau_plugin Dir/"                     pubspec.yaml

        # gsed -i  "s/^\(<\!-- static\) -->$/\1/"                                                                       example/web/index.html
        # gsed -i  "s/^\(<\!-- dynamic\)$/\1 -->/"                                                                      example/web/index.html

        # gsed -i  "s/^ *flutter_sound_web: *#* *\(.*\)$/  flutter_sound_web: \1/"                                                                              flutter_sound/pubspec.yaml
        # gsed -i  "s/^ *path: \.\.\/flutter_sound_web # Flutter Sound Dir$/#    path: \.\.\/flutter_sound_web # Flutter Sound Dir/"                            flutter_sound/pubspec.yaml
        # gsed -i  "s/^ *flauto_web: *#* *\(.*\)$/  flauto_web: \1/"                                                                                            flutter_sound/pubspec.yaml
        # gsed -i  "s/^ *path: \.\.\/flauto_web # Flutter Sound Dir$/#    path: \.\.\/flauto_web # Flutter Sound Dir/"                                          flutter_sound/pubspec.yaml
        # gsed -i  "s/^ *#* *flutter_sound_web: *#* *\(.*\)$/#  flutter_sound_web: \1/"                                                                         flutter_sound/example/pubspec.yaml
        # gsed -i  "s/^ *path: \.\.\/\.\.\/flutter_sound_web # flutter_sound_web Dir$/#    path: \.\.\/\.\.\/flutter_sound_web # flutter_sound_web Dir/"        flutter_sound/example/pubspec.yaml
        # gsed -i  "s/^ *#* *flauto_web: *#* *\(.*\)$/#  flauto_web: \1/"                                                                                       flutter_sound/example/pubspec.yaml
        # gsed -i  "s/^ *path: \.\.\/\.\.\/flauto_web # flutter_sound_web Dir$/#    path: \.\.\/\.\.\/flauto_web # flutter_sound_web Dir/"                      flutter_sound/example/pubspec.yaml

        # gsed -i  "s/^ *pod 'flutter_sound_core',\(.*\)$/# pod 'flutter_sound_core',\1/"                                                                       flutter_sound/example/ios/Podfile

        exit 0

#========================================================================================================================================================================================================


elif [ "_$1" = "_DEV" ]; then
        echo 'DEV mode'
        echo '--------'

        gsed -i  "s/^ *tau: *#* *\(.*\)$/  tau: # \1/"                                                                  example/pubspec.yaml
        gsed -i  "s/^ *# path: \.\.\/ # Tau Dir$/    path: \.\.\/ # Tau Dir/"                                           example/pubspec.yaml

        gsed -i  "s/^ *tau_plugin: *#* *\(.*\)$/  tau_plugin: # \1/"                                                    example/pubspec.yaml
        gsed -i  "s/^ *# path: \.\.\/tau_plugin # tau_plugin Dir$/    path: \.\.\/tau_plugin # tau_plugin Dir/"         example/pubspec.yaml

        gsed -i  "s/^ *tau_plugin: *#* *\(.*\)$/  tau_plugin: # \1/"                                                    tau_plugin/example/pubspec.yaml
        gsed -i  "s/^ *# path: \.\.\/ # tau_plugin Dir$/    path: \.\.\/ # tau_plugin Dir/"         tau_plugin/example/pubspec.yaml

        gsed -i  "s/^ *tau_plugin: *#* *\(.*\)$/  tau_plugin: # \1/"                                                    pubspec.yaml
        gsed -i  "s/^ *# path: tau_plugin # tau_plugin Dir$/    path: tau_plugin # tau_plugin Dir/"                     pubspec.yaml

        # gsed -i  "s/^\( *<\!-- dynamic\) -->$/\1/"                                                                    example/web/index.html
        # gsed -i  "s/^\( *<\!-- dynamic\)$/\1 -->/"                                                                    example/web/index.html
        # gsed -i  "s/^\( *<\!-- static\)$/\1 -->/"                                                                     example/web/index.html
        # gsed -i  "s/^\( *<\!-- static\) -->$/\1/"                                                                     example/web/index.html

        # gsed -i  "s/^ *flutter_sound_web: *#* *\(.*\)$/  flutter_sound_web: # \1/"                                                                            flutter_sound/pubspec.yaml
        # gsed -i  "s/^# *path: \.\.\/flutter_sound_web # Flutter Sound Dir$/    path: \.\.\/flutter_sound_web # Flutter Sound Dir/"                            flutter_sound/pubspec.yaml
        # gsed -i  "s/^ *flauto_web: *#* *\(.*\)$/  flauto_web: # \1/"                                                                                          flutter_sound/pubspec.yaml
        # gsed -i  "s/^# *path: \.\.\/flauto_web # Flutter Sound Dir$/    path: \.\.\/flauto_web # Flutter Sound Dir/"                                          flutter_sound/pubspec.yaml
        # gsed -i  "s/^ *#* *flutter_sound_web: *#* *\(.*\)$/  flutter_sound_web: # \1/"                                                                        flutter_sound/example/pubspec.yaml
        # gsed -i  "s/^# *path: \.\.\/\.\.\/flutter_sound_web # flutter_sound_web Dir$/    path: \.\.\/\.\.\/flutter_sound_web # flutter_sound_web Dir/"        flutter_sound/example/pubspec.yaml
        # gsed -i  "s/^ *#* *flauto_web: *#* *\(.*\)$/  flauto_web: # \1/"                                                                                      flutter_sound/example/pubspec.yaml
        # gsed -i  "s/^# *path: \.\.\/\.\.\/flauto_web # flutter_sound_web Dir$/    path: \.\.\/\.\.\/flauto_web # flutter_sound_web Dir/"                      flutter_sound/example/pubspec.yaml

        # gsed -i  "s/^ *# pod 'flutter_sound_core',\(.*\)$/pod 'flutter_sound_core',\1/"                                                                       flutter_sound/example/ios/Podfile

        exit 0

else
        echo "Correct syntax is $0 [REL | DEV]"
        exit -1
fi
echo "Done"
