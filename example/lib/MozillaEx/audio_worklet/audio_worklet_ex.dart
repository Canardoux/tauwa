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

/// This is a very simple example for τ beginners, that show how to playback a file.
/// Its a translation to Dart from [Mozilla example](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Using_Web_Audio_API)
/// This example is really basic.
class AudioWorkletEx extends StatefulWidget {
  const AudioWorkletEx({super.key});
  @override
  State<AudioWorkletEx> createState() => _AudioWorkletEx();
}

class _AudioWorkletEx extends State<AudioWorkletEx> {
  AudioContext? audioContext;
  AudioDestinationNode? dest;
  GainNode? gainNode;

  bool hissGainRangeDisabled = true;
  bool oscGainRangeDisabled = true;

  double oscGainValue = 0.2;
  double hissGainValue = 0.2;

  Future<void> createHissProcessor() async {
    audioContext ??= AudioContext(
        options: const AudioContextOptions(
      latencyHint: AudioContextLatencyCategory.playback(),
      sinkId: '',
      renderSizeHint: AudioContextRenderSizeCategory.default_,
      //sampleRate: 44100,
    ));

    //AudioWorkletNode processorNode = AudioWorkletNode();
  }

  void initPlatformState() async {
    /*
    await loadAudio();
    audioBuffer = audioContext!.decodeAudioDataSync(inputPath: path);
    double duration = audioBuffer!.duration();
    max = duration; // The value is incorrect !
     */
    setState(() {});

    Tauwa.tauwa.logger.d('Une bonne journée');
  }

  // And here is our dart code
  Future<void> toggleSound() async {
    if (audioContext == null) {
      //audioDemoStart();

      hissGainRangeDisabled = false;
      oscGainRangeDisabled = false;
    } else {
      hissGainRangeDisabled = true;
      oscGainRangeDisabled = true;

      await audioContext!.close();
      audioContext!.dispose();
      audioContext = null;
    }
  }

  Future<void> hissGain(double v) async // v is between 0.0 and max
  {
    hissGainValue = v;
    //int h = hissGenNode!.parameters();
    setState(() {});
  }

  Future<void> oscGain(double v) async // v is between 0.0 and max
  {
    oscGainValue = v;
    gainNode!.gain.value = v;
    //gainNode!.gain.setValueAtTime( value: v, startTime: audioContext!.currentTime() ) = v;
    setState(() {});
  }

  // Good citizens must dispose nodes and Audio Context
  void disposeEverything() {
    Tauwa.tauwa.logger.d("dispose");

    if (dest != null) {
      dest!.dispose();
      dest = null;
    }
  }

  @override
  void dispose() {
    disposeEverything();
    if (audioContext != null) {
      audioContext!.close();
      audioContext!.dispose();
      audioContext = null;
    }
    /*
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
    
     */

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
              onPressed: toggleSound,
              //color: Colors.indigo,
              child: const Text(
                'Toggle Sound',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ]),
          const SizedBox(
            height: 20,
          ),
          const Text('Oscillator gain:'),
          Slider(
            value: oscGainValue,
            min: 0.0,
            max: 1.0,
            onChanged: oscGain,
            //divisions: 1
          ),
          const SizedBox(
            height: 20,
          ),
          const Text('Hiss gain:'),
          Slider(
            value: hissGainValue,
            min: 0.0,
            max: 1.0,
            onChanged: hissGain,

            //divisions: 1
          ),
        ]),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Mozilla Audio Source Buffer Loop'),
        actions: const <Widget>[],
      ),
      body: makeBody(),
    );
  }
}
