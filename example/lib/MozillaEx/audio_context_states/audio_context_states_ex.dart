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
class AudioContextStatesEx extends StatefulWidget {
  const AudioContextStatesEx({super.key});
  @override
  State<AudioContextStatesEx> createState() => _AudioContextStatesEx();
}

class _AudioContextStatesEx extends State<AudioContextStatesEx> {
  String pcmAsset =
      'assets/samples-f32/sample-f32-48000-32kb_s.pcm'; // The Raw PCM asset to be played

  AudioContext? audioCtx;
  AudioDestinationNode? dest;
  AudioBufferSourceNode? source;
  OscillatorNode? oscillator;
  GainNode? gainNode;
  bool createContextDisabled = false;
  bool suspendContextDisabled = true;
  bool stopContextDisabled = true;
  String p = 'Current context time: No context exists.';
  String susresBtn = "Suspend context";

  Future<Float32List> getAssetData(String path) async {
    var asset = await rootBundle.load(path);
    return asset.buffer.asFloat32List();
  }

  // And here is our dart code

  void disposeEverything()
  {
    if (dest != null) {
      dest!.dispose();
      dest = null;
    }

    if (audioCtx != null) {
      audioCtx!.close();
      audioCtx!.dispose();
      audioCtx = null;
    }
    if (source != null) {
        //source!.stop();
        source!.dispose();
        source = null;
    }

    if (oscillator != null)
      {
        oscillator!.dispose();
        oscillator = null;
      }

    if (gainNode != null)
      {
        gainNode!.dispose();
        gainNode = null;
      }

  }
  @override
  void dispose() {
    disposeEverything();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> createContext() async {
    createContextDisabled = true;
    suspendContextDisabled = false;
    stopContextDisabled = false;
    disposeEverything();
    audioCtx = AudioContext(
        options: const AudioContextOptions(
      latencyHint: AudioContextLatencyCategory.playback(),
      sinkId: '',
      renderSizeHint: AudioContextRenderSizeCategory.default_,
      sampleRate: 44100,
    ));

    oscillator = audioCtx!.createOscillator();
    oscillator!.frequency.value = 100;
    oscillator!.setType(type: OscillatorType.square);
    gainNode = audioCtx!.createGain();
    gainNode!.gain.value = 0.1;
    dest = audioCtx!.destination();
    oscillator!.connect(dest: gainNode!);
    gainNode!.connect(dest: dest!);
    oscillator!.start();
    audioCtx!.setOnStateChange(callback: (Event event) {
      if (audioCtx == null)
        {
          Tauwa.tauwa.logger.i('Audio Context is null');
        } else
        {
          AudioContextState state = audioCtx!.state();
          Tauwa.tauwa.logger.i(state.toString());
        }
    });

    setState(() {});

    Tauwa.tauwa.logger.d('Une bonne journée');
  }

  Future<void> suspendContext() async
  {
    AudioContextState state = audioCtx!.state();
    if (state == AudioContextState.running) {
      await audioCtx!.suspend().then((v)  {
      susresBtn = "Resume context";
      });
    } else if (state == AudioContextState.suspended) {
      audioCtx!.resumeSync();
      susresBtn = "Suspend context";
    }
    setState(() {});

  }

  Future<void> stopContext() async
  {
    audioCtx!.close().then((v)
    {
      createContextDisabled = false;
      suspendContextDisabled = true;
      // Reset the text of the suspend/resume toggle:
      susresBtn = "Suspend context";
      stopContextDisabled = true;
      setState(() {});
    });

  }

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: createContextDisabled ? null : createContext,
              //color: Colors.indigo,
              child: const Text(
                'Create Context',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            ElevatedButton(
              onPressed: suspendContextDisabled ? null : suspendContext,
              //color: Colors.indigo,
              child:  Text(
                susresBtn,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            ElevatedButton(
              onPressed: stopContextDisabled ? null : stopContext,
              //color: Colors.indigo,
              child: const Text(
                'Stop Context',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ]),
          Text(p)
        ]),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Mozilla Audio Context States'),
        actions: const <Widget>[],
      ),
      body: makeBody(),
    );
  }
}
