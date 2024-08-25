/*
 * Copyright 2024 Canardoux.
 *
 * This file is part of the τ Project.
 *
 * τ (Tau) is free software: you can redistribute it and/or modify
 * it under the terms of the Mozilla Public License version 2 (MPL2.0),
 * as published by the Mozilla organization.
 *
 * τ is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * MPL General Public License for more details.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/// ------------------------------------------------------------------
/// # The Flutter Sound library
///
/// Flutter Sound is composed with four main modules/classes
/// - [FlutterSound]. This is the main Flutter Sound module.
/// - [FlutterSoundPlayer]. Everything about the playback functions
/// - [FlutterSoundRecorder]. Everything about the recording functions
/// - [FlutterSoundHelper]. Some utilities to manage audio data.
/// And two modules for the Widget UI
/// - [SoundPlayerUI]
/// - [SoundRecorderUI]
/// ------------------------------------------------------------------
//library tau;

/// everything : no documentation
/// @nodoc
library everything;

import 'dart:async';
import 'package:logger/logger.dart' as lg;
import 'package:tauwa/public/rust/frb_generated.dart';
import 'package:tauwa/public/rust/api/simple.dart';

//export 'package:logger/logger.dart' as lg;
export 'package:tauwa/public/rust/frb_generated.dart';
export 'package:tauwa/public/rust/api/simple.dart';
//export 'package:tauwa/public/rust/api/simple.dart';
export 'package:tauwa/public/rust/api/toto.dart';
export 'package:tauwa/public/rust/third_party/web_audio_api.dart';
//export 'package:tauwa/public/rust/frb_generated.dart';
export 'package:tauwa/public/rust/third_party/web_audio_api/context.dart';
export 'package:tauwa/public/rust/third_party/web_audio_api/media_devices.dart';
export 'package:tauwa/public/rust/third_party/web_audio_api/media_recorder.dart';
export 'package:tauwa/public/rust/third_party/web_audio_api/media_streams.dart';
export 'package:tauwa/public/rust/third_party/web_audio_api/node.dart';
export 'package:tauwa/public/rust/third_party/web_audio_api/worklet.dart';
export 'package:tauwa/public/rust/api/override_web_audio_api.dart';
export 'package:tauwa/public/rust/api/media_element.dart';

//==================================  Tau  ======================================

/// This is the Main class for the τ Plugin.
/// Tau() or [tau] is a Singleton.
/// The module is automatically inited, thanks to the static variable [tauwa].
class Tauwa {
  /// Tauwa() and [tauwa] are synonymous.
  static final Tauwa tauwa = Tauwa._internal();

  /// Tau() is a singleton
  factory Tauwa() {
    return tauwa;
  }

  Tauwa._internal() {
    //init(lev: lg.Level.trace);
  }

  /// Enums are transmitted with Int between Tau and TauCore
  /// [iToLevel] translates Rust Level to Dart Level
  final iToLevel = [
    lg.Level.error,
    lg.Level.warning,
    lg.Level.info,
    lg.Level.debug,
    lg.Level.trace
  ];

  /// The stream for receiving logs from the TauCore module.
  Future<void> _setup() async {
    traceLogger().listen((event) {
      logger.log(
        iToLevel[event.logLevel.index],
        "[${event.lbl}] ${event.msg}",
        time: DateTime.fromMillisecondsSinceEpoch(event.timeMillis),
      );
    });
  }

  /// Initialisation of the full plugin after a clean startup
  /// - [level] is the log level for the plugin. It is optional.
  /// This function is automatically called by the Tau singleton with a default og level of logger.Level.trace.
  /// Call `setLogLevel()` if another log level is wanted
  /// Probably never called by the App
  Future<void> init({lg.Level lev = lg.Level.trace}) async {
    await RustLib.init(); // Initialisation of the Flutter-Rust-Bridge
    initTauCore(); // Initialisation of the TauCore module
    setLogLevel(lev); // Initialisation of the Logger
    await _setup(); // Creation of the Stream to receive Logs from TauCore.
    //String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    //platformVersion = await TauPlugin.tauPlugin.getPlatformVersion() ??
    //'Unknown platform version';

    //logger.t('Running on: $platformVersion\n');
  }

  /// The Tau Logger and the current Log level.
  /// They are private static variable
  lg.Logger _logger = lg.Logger(level: lg.Level.trace);
  lg.Level _logLevel = lg.Level.debug;

  /// The FlutterSoundPlayerLogger Logger and logLevel getters
  /// Getter (read only)
  lg.Logger get logger => _logger;
  lg.Level get logLevel => _logLevel;

  /// Used if the App wants to dynamically change the Log Level.
  /// - [aLevel] is the new log level wanted
  void setLogLevel(lg.Level aLevel) async {
    _logLevel = aLevel;
    _logger = lg.Logger(level: aLevel);
    rustSetLogLevel(level: aLevel.index);
  }
}

/// Name of the module
const String _libName = 'tau';
