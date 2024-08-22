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

import 'package:flutter/material.dart';
import 'package:tauwa/tauwa.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';

/// This is a very simple example for τ beginners, that show how to playback a file.
/// Its a translation to Dart from [Mozilla example](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Using_Web_Audio_API)
/// This example is really basic.
class OfflineAudioContextPromiseEx extends StatefulWidget {
  const OfflineAudioContextPromiseEx({super.key});
  @override
  State<OfflineAudioContextPromiseEx> createState() => _OfflineAudioContextPromiseEx();
}

class _OfflineAudioContextPromiseEx extends State<OfflineAudioContextPromiseEx> {
  String pcmAsset = 'assets/wav/sample2.aac'; // The Wav asset to be played

  AudioContext? audioCtx;
  OfflineAudioContext? offlineCtx;
  AudioDestinationNode? dest;
  AudioBufferSourceNode? source;
  AudioBufferSourceNode? song ;
  AudioBuffer? audioBuffer;
  final channels = 1;
  bool playDisabled = false;
  bool stopDisabled = true;
  var path = '';
  double loopStartValue = 0;
  double loopEndValue = 0;
  double max = 0;

  Future<void> loadAudio() async {
    var asset = await rootBundle.load(pcmAsset);

    var tempDir = await getTemporaryDirectory();
    path = '${tempDir.path}/tau.aac';
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

  Future<void> hitPlayButton() async
  {
    offlineCtx =  OfflineAudioContext(numberOfChannels: 2, length: 44100 * 100,sampleRate: 44100);

    loadAudio().then((_){return audioCtx!.decodeAudioDataSync(inputPath: path);})
        .then( (decodedBuffer)
    {
      source = offlineCtx!.createBufferSource();
      source!.setBuffer(audioBuffer: decodedBuffer);
      dest = offlineCtx!.destination();
      source!.connect(dest: dest!);
      return source!.start();
    })
        .then( (_){return offlineCtx!.startRendering();})
        .then ((renderedBuffer){
       song = audioCtx!.createBufferSource();
      song!.setBuffer(audioBuffer: renderedBuffer);
      var onLineDest = audioCtx!.destination();
      song!.connect(dest:onLineDest);
      song!.start();
    });
    playDisabled = true;
    stopDisabled = false;

          if (mounted) {
            setState(() {});
          }
  }

  Future<void> hitStopButton() async {
    source!.stop();
    song!.stop();
    playDisabled = false;
    stopDisabled = true;
    if (mounted) {
      setState(() {});
    }
  }


  @override
  void dispose() {
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
            const SizedBox(
              width: 5,
            ),
            ElevatedButton(
              onPressed: stopDisabled ? null : hitStopButton,
              //color: Colors.indigo,
              child: const Text(
                'Stop',
                style: TextStyle(color: Colors.black),
              ),
            ),

          ]),


            //divisions: 1
        ]),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Mozilla Offline Audio Context Promise'),
        actions: const <Widget>[],
      ),
      body: makeBody(),
    );
  }
}
