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
class PlaybackRateEx extends StatefulWidget {
  const PlaybackRateEx({super.key});
  @override
  State<PlaybackRateEx> createState() => _PlaybackRateEx();
}

class _PlaybackRateEx extends State<PlaybackRateEx> {
  String pcmAsset =
      'assets/samples-f32/sample-f32-48000-32kb_s.pcm'; // The Raw PCM asset to be played

  AudioContext? audioCtx;
  AudioDestinationNode? dest;
  AudioBufferSourceNode? source;
  AudioBuffer? audioBuffer;
  bool playDisabled = false;
  bool stopDisabled = true;
  var path = '';
  var playBackRateValue = 1.0;

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

    Tauwa.tauwa.logger.d('Une bonne journée');
    Float32List pcmData = await getAssetData(pcmAsset);

    audioBuffer = AudioBuffer.from(
        samples: List<Float32List>.filled(2, pcmData), sampleRate: 48000);

    setState(() {});

    Tauwa.tauwa.logger.d('Une bonne journée');
  }

  // And here is our dart code
  Future<void> hitPlayButton() async {
    if (source != null) {
      //source!.stop();
      source!.dispose();
      source = null;
    }
    source = audioCtx!.createBufferSource();

    //var audioBufferCloned = audioBuffer!.clone();
    source!.setBuffer(audioBuffer: audioBuffer!);
    if (audioBuffer!.isDisposed) {
      Tauwa.tauwa.logger.d('Is disposed');
    }

    dest = audioCtx!.destination();
    source!.connect(dest: dest!);
    source!.setLoop(value: true);

    //source.loopStart = loopstartControl.value;
    //source.loopEnd = loopendControl.value;
    playBackRateChanged(1.0);
    source!.start();
    playDisabled = true;
    stopDisabled = false;

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> hitStopButton() async {
    source!.stop();
    playDisabled = false;
    stopDisabled = true;
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

  void playBackRateChanged(double value) {
    playBackRateValue = value;
    source!.playbackRate.value = value;
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
            const SizedBox(
              width: 5,
            ),
          ]),
          const SizedBox(
            height: 20,
          ),
          const Text('Playback Rate:'),
          Slider(
            value: playBackRateValue,
            min: 0.25,
            max: 3,
            onChanged: playBackRateChanged,
            //divisions: 1
          ),
        ]),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Mozilla Playback Rate'),
        actions: const <Widget>[],
      ),
      body: makeBody(),
    );
  }
}
