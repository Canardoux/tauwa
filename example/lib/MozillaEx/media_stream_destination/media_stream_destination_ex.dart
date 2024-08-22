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

/// This is a very simple example for τ beginners, that show how to playback a file.
/// Its a translation to Dart from [Mozilla example](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Using_Web_Audio_API)
/// This example is really basic.
class MediaStreamDestinationEx extends StatefulWidget {
  const MediaStreamDestinationEx({super.key});
  @override
  State<MediaStreamDestinationEx> createState() => _MediaStreamDestinationEx();
}

class _MediaStreamDestinationEx extends State<MediaStreamDestinationEx> {

  AudioContext? audioCtx;
  bool clicked = false;
  bool btnDisabled = false;
  var chunks = [];
  late OscillatorNode osc;
  late MediaStreamAudioDestinationNode dest;
  late MediaRecorder mediaRecorder;

  void initPlatformState() async {
    audioCtx = AudioContext(
        options: const AudioContextOptions(
      latencyHint: AudioContextLatencyCategory.playback(),
      sinkId: '',
      renderSizeHint: AudioContextRenderSizeCategory.default_,
      //sampleRate: 44100,
    ));
    osc = audioCtx!.createOscillator();
    osc.frequency.value = 100;
    osc.setType(type: OscillatorType.sine);

    dest = audioCtx!.createMediaStreamDestination();
    mediaRecorder = MediaRecorder(stream: dest.stream());
    osc.connect(dest: dest);
    mediaRecorder.setOnDataAvailable( callback: (evt)
    {
      chunks.addAll(evt.blob );
    } );
    mediaRecorder.setOnStop(callback:
      (event)
      {
        Tauwa.tauwa.logger.i('OnStopped');
      }
    );
    setState(() {});

    Tauwa.tauwa.logger.d('Une bonne journée');
  }


  Future<void> hitButton() async {

    if (!clicked)
    {
          mediaRecorder.start();
          osc.start();
          clicked = true;
    } else
    {
          //mediaRecorder.requestData();
          mediaRecorder.stop();
          osc.stop();
          btnDisabled = true;

    }
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
              onPressed: btnDisabled ? null : hitButton,
              //color: Colors.indigo,
              child:  Text( clicked ? 'Stop Recording' :
                'Make sine wave',
                style: const TextStyle(color: Colors.black),
              ),
            ),
           ]),
      ]));
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Mozilla Create Media Stream Destination'),
        actions: const <Widget>[],
      ),
      body: makeBody(),
    );
  }
}
