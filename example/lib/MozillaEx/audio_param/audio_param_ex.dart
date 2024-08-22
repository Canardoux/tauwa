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
class AudioParamEx extends StatefulWidget {
  const AudioParamEx({super.key});
  @override
  State<AudioParamEx> createState() => _AudioParamEx();
}

class _AudioParamEx extends State<AudioParamEx> {
  String pcmAsset = 'assets/wav/viper.ogg'; // The OGG asset to be played

  AudioContext? audioCtx;
  AudioDestinationNode? dest;
  AudioBufferSourceNode? source;
  AudioBuffer? audioBuffer;
  GainNode? gainNode;
  double curGain = 0;

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
    dest = audioCtx!.destination();
    await loadAudio();
    audioBuffer = audioCtx!.decodeAudioDataSync(inputPath: path);
    source = audioCtx!.createBufferSource();
    source!.setBuffer(audioBuffer: audioBuffer!);
    gainNode = audioCtx!.createGain();
    curGain = gainNode!.gain.value;

    source!.connect(dest: gainNode!);
    gainNode!.connect(dest: dest!);
    source!.start();
    source!.loopEnd();
    setState(() {});

    Tauwa.tauwa.logger.d('Une bonne journée');
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

   List<double> waveArray =  [0.5, 1, 0.5, 0, 0.5, 1, 0, 0.5];

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: (){curGain += 0.25; gainNode!.gain.setValueAtTime(value: curGain, startTime: audioCtx!.currentTime() + 1);},
              //color: Colors.indigo,
              child: const Text(
                'Set Gain +0.25 in 1 second',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            ElevatedButton(
              onPressed:  (){curGain -= 0.25; gainNode!.gain.setValueAtTime(value: curGain, startTime: audioCtx!.currentTime() + 1);},
              //color: Colors.indigo,
              child: const Text(
                'Set Gain -0.25 in 1 second',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ]),
          const SizedBox(
            height: 20,
          ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed:  (){curGain =1.0; gainNode!.gain.linearRampToValueAtTime(value: curGain, endTime:  audioCtx!.currentTime() + 2);},
              //color: Colors.indigo,
              child: const Text(
                'Linear ramp gain to 1 in 2 seconds',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            ElevatedButton(
              onPressed: (){curGain =0.0; gainNode!.gain.linearRampToValueAtTime(value: curGain, endTime:  audioCtx!.currentTime() + 2);},
              //color: Colors.indigo,
              child: const Text(
                'Linear ramp gain to 0 in 2 seconds',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ]),
          const SizedBox(
            height: 20,
          ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed:  (){curGain =1.0; gainNode!.gain.exponentialRampToValueAtTime(value: curGain, endTime:  audioCtx!.currentTime() + 2);},
              //color: Colors.indigo,
              child: const Text(
                'Exponential ramp gain to 1 in 2 seconds',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            ElevatedButton(
              onPressed:  (){curGain =0.01; gainNode!.gain.exponentialRampToValueAtTime(value: 0.01, endTime:  audioCtx!.currentTime() + 2);},
              //color: Colors.indigo,
              child: const Text(
                'Exponential ramp gain to 0 in 2 seconds',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ]),
          const SizedBox(
            height: 20,
          ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed:  (){curGain =1.0; gainNode!.gain.setTargetAtTime(value: curGain, startTime:  audioCtx!.currentTime() + 1, timeConstant: 0.5);},
              //color: Colors.indigo,
              child: const Text(
                'Target at time 1 in 1s',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            ElevatedButton(
              onPressed: (){curGain =0.0; gainNode!.gain.setTargetAtTime(value: curGain, startTime:  audioCtx!.currentTime() + 1, timeConstant: 0.5);},
              //color: Colors.indigo,
              child: const Text(
                'Target at time 0 in 1s',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ]),
          const SizedBox(
            height: 20,
          ),
                      ElevatedButton(
              onPressed:  (){ gainNode!.gain.setValueCurveAtTime(values: waveArray, startTime: audioCtx!.currentTime() , duration: 2);},
              //color: Colors.indigo,
              child: const Text(
                'Value curve',
                style: TextStyle(color: Colors.black),
              ),
            ),

        ]),
      );
    }
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Mozilla Audio Param'),
        actions: const <Widget>[],
      ),
      body: makeBody(),
    );
  }
}
