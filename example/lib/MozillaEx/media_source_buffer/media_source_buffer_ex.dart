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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tauwa/tauwa.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';

/// This is a very simple example for τ beginners, that show how to playback a file.
/// Its a translation to Dart from [Mozilla example](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Using_Web_Audio_API)
/// This example is really basic.
class MediaSourceBufferEx extends StatefulWidget {
  const MediaSourceBufferEx({super.key});
  @override
  State<MediaSourceBufferEx> createState() => _MediaSourceBufferEx();
}

class _MediaSourceBufferEx extends State<MediaSourceBufferEx> {
  String pcmAsset = 'assets/wav/viper.ogg'; // The OGG asset to be played

  AudioContext? audioCtx;
  AudioDestinationNode? dest;
  MediaElementAudioSourceNode? source;
  AudioBuffer? audioBuffer;
  GainNode? gainNode;

  bool playDisabled = false;
  bool stopDisabled = true;
  double volumeValue = 0;
  String path = '';

  Future<void> loadAudio() async {
    var asset = await rootBundle.load(pcmAsset);

    var tempDir = await getTemporaryDirectory();
    path = '${tempDir.path}/tau.wav';
    var file = File(path);
    file.writeAsBytesSync(asset.buffer.asInt8List());
  }

  void initPlatformState() async {
    audioCtx = AudioContext(
        options: const AudioContextOptions(
      latencyHint: AudioContextLatencyCategory.playback(),
      sinkId: '',
      renderSizeHint: AudioContextRenderSizeCategory.default_,
      //sampleRate: 44100,
    ));
    setState(() {});

    Tauwa.tauwa.logger.d('Une bonne journée');
  }



  Future<void> hitPlayButton() async {
    disposeEverything();


    dest = audioCtx!.destination();
    await loadAudio();
    var media = MediaElement(file: path);

    source = audioCtx!.createMediaElementSource(mediaElement: media);
    source!.connect(dest: dest!);
    playDisabled = true;
    stopDisabled = false;

    if (mounted) {
      setState(() {});
    }
  }

  // Good citizens must dispose nodes and Audio Context
  void disposeEverything() {
    Tauwa.tauwa.logger.d("dispose");

    if (dest != null) {
      dest!.dispose();
      dest = null;
    }
    //if (source != null) {
    //src!.stop();
    //source!.dispose();
    //source = null;
    //}
  }

  @override
  void dispose() {
    disposeEverything();
    if (audioCtx != null) {
      audioCtx!.close();
      audioCtx!.dispose();
      audioCtx = null;
      if (source != null) {
        //source!.stop();
        source!.dispose();
        source = null;
      }
      if (audioBuffer != null) {
        audioBuffer!.dispose();
        audioBuffer = null;
      }
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void volumeChanged(double value) {
    volumeValue = value;
    gainNode!.gain.value = value;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: playDisabled ? null : hitPlayButton,
              //color: Colors.indigo,
              child: const Text(
                'Play',
                style: TextStyle(color: Colors.black),
              ),
            ),
           ]),
          const SizedBox(
            height: 20,
          ),
          const Text('Volume:'),
          Slider(
            value: volumeValue,
            min: 0,
            max: 1,
            onChanged: volumeChanged,
            //divisions: 1
          ),
        ]),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Mozilla Media Source Buffer Node'),
        actions: const <Widget>[],
      ),
      body: makeBody(),
    );
  }
}
