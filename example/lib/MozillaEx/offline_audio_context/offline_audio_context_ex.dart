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
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

/// This is a very simple example for τ beginners, that show how to playback a file.
/// Its a translation to Dart from [Mozilla example](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Using_Web_Audio_API)
/// This example is really basic.
class OfflineAudioContextEx extends StatefulWidget {
  const OfflineAudioContextEx({super.key});
  @override
  State<OfflineAudioContextEx> createState() => _OfflineAudioContextEx();
}

class _OfflineAudioContextEx extends State<OfflineAudioContextEx> {
  String pcmAsset =
      'assets/samples-f32/sample-f32-48000-32kb_s.pcm'; // The Raw PCM asset to be played

  AudioContext? audioCtx;
  OfflineAudioContext? offlineCtx;
  AudioDestinationNode? dest;
  AudioBufferSourceNode? source;

  AudioBuffer? audioBuffer;
  bool playDisabled = false;

  Future<Float32List> getAssetData(String path) async {
    var asset = await rootBundle.load(path);
    return asset.buffer.asFloat32List();
  }

  void initPlatformState() async {
    audioCtx = AudioContext(
        options: const AudioContextOptions(
      latencyHint: AudioContextLatencyCategory.playback(),
      sinkId: '',
      renderSizeHint: AudioContextRenderSizeCategory.default_,
      sampleRate: 48000,
    ));

    offlineCtx = OfflineAudioContext(
        length: 44100 * 40, numberOfChannels: 2, sampleRate: 48000);
    Tauwa.tauwa.logger.d('Une bonne journée');
    Float32List pcmData = await getAssetData(pcmAsset);

    audioBuffer = AudioBuffer.from(
        samples: List<Float32List>.filled(2, pcmData), sampleRate: 48000);

    source = offlineCtx!.createBufferSource();

    //var audioBufferCloned = audioBuffer!.clone();
    source!.setBuffer(audioBuffer: audioBuffer!);
    offlineCtx!.setOnComplete(callback: finished);
    dest = offlineCtx!.destination();
    source!.connect(dest: dest!);

    setState(() {});

    Tauwa.tauwa.logger.d('Une bonne journée');
  }

  Future<void> finished(OfflineAudioCompletionEvent event) async {
    AudioBufferSourceNode src = audioCtx!.createBufferSource();
    src.setBuffer(audioBuffer: event.renderedBuffer);

    AudioDestinationNode dest = audioCtx!.destination();
    src.connect(dest: dest);
    src.start();
  }

  // And here is our dart code
  Future<void> hitPlayButton() async {
    playDisabled = true;
    source!.start();
    offlineCtx!.startRendering();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (dest != null) {
      dest!.dispose();
      dest = null;
    }

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
          ]),
          const SizedBox(
            height: 20,
          ),
        ]),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Mozilla Offline Audio Context'),
        actions: const <Widget>[],
      ),
      body: makeBody(),
    );
  }
}
