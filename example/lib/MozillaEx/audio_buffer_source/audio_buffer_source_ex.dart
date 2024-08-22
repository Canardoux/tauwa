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

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tauwa/tauwa.dart';
import 'dart:math';

/// This is a very simple example for τ beginners, that show how to playback a file.
/// Its a translation to Dart from [Mozilla example](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Using_Web_Audio_API)
/// This example is really basic.
class AudioBufferSourceEx extends StatefulWidget {
  const AudioBufferSourceEx({super.key});
  @override
  State<AudioBufferSourceEx> createState() => _AudioBufferSourceEx();
}

class _AudioBufferSourceEx extends State<AudioBufferSourceEx> {
  AudioContext? audioCtx;
  AudioBuffer? audioBuffer;
  AudioDestinationNode? dest;
  AudioBufferSourceNode? src;
  final channels = 2;

  void initPlatformState() async {
    audioCtx = AudioContext(
        options: const AudioContextOptions(
      latencyHint: AudioContextLatencyCategory.playback(),
      sinkId: '',
      renderSizeHint: AudioContextRenderSizeCategory.default_,
      sampleRate: 48000,
    ));

    Tauwa.tauwa.logger.d('Une bonne journée');
  }

  // Here is the JS code executed when click on the button
  /*
      // Create an empty two second stereo buffer at the
      // sample rate of the AudioContext
      const frameCount = audioCtx.sampleRate * 2.0;

      const buffer = new AudioBuffer({
        numberOfChannels: channels,
        length: frameCount,
        sampleRate: audioCtx.sampleRate,
      });

      // Fill the buffer with white noise;
      // just random values between -1.0 and 1.0
      for (let channel = 0; channel < channels; channel++) {
        // This gives us the actual array that contains the data
        const nowBuffering = buffer.getChannelData(channel);
        for (let i = 0; i < frameCount; i++) {
          // Math.random() is in [0; 1.0]
          // audio needs to be in [-1.0; 1.0]
          nowBuffering[i] = Math.random() * 2 - 1;
        }
      }

      // Get an AudioBufferSourceNode.
      // This is the AudioNode to use when we want to play an AudioBuffer
      const source = audioCtx.createBufferSource();
      // Set the buffer in the AudioBufferSourceNode
      source.buffer = buffer;
      // Connect the AudioBufferSourceNode to the
      // destination so we can hear the sound
      source.connect(audioCtx.destination);
      // start the source playing
      source.start();

      source.onended = () => {
        console.log("White noise finished.");
      };
 */
  // And here is our dart code
  Future<void> hitPlayButton() async {
    disposeEverything();
    var sampleRate = audioCtx!.sampleRate();
    var frameCount = (sampleRate * 2.0).ceil();
    List<Float32List> buf = List<Float32List>.filled(
        channels,
        Float32List(
          frameCount,
        ));
    List<Float32List>.filled(channels, Float32List(frameCount));
    src = audioCtx!.createBufferSource();
    for (int channel = 0; channel < channels; ++channel) {
      Float32List nowBuffering = Float32List(frameCount);
      for (int i = 0; i < frameCount; ++i) {
        double rng = (Random().nextDouble() * 2) - 1;
        nowBuffering[i] = rng;
      }
      buf[channel] = nowBuffering;
    }
    AudioBuffer audioBuffer =
      AudioBuffer.from(samples: buf, sampleRate: 48000);

    src = audioCtx!.createBufferSource();
    src!.setBuffer(audioBuffer: audioBuffer);
    audioBuffer.dispose();

    dest = audioCtx!.destination();
    src!.connect(dest: dest!);
    src!.setOnEnded(callback: finished);
    src!.start();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> finished(Event event) async {
    Tauwa.tauwa.logger.d('lolo');
    src!.stop();
    setState(() {});

    Tauwa.tauwa.logger.d('C\'est parti mon kiki');
    setState(() {});
  }

  // Good citizens must dispose nodes and Auddio Context
  void disposeEverything() {
    Tauwa.tauwa.logger.d("dispose");

    if (dest != null) {
      dest!.dispose();
      dest = null;
    }
    if (src != null) {
      //src!.stop();
      src!.dispose();
      src = null;
    }
    if (audioBuffer != null) {
      audioBuffer!.dispose();
      audioBuffer = null;
    }
  }

  @override
  void dispose() {
    disposeEverything();
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
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(
          onPressed: hitPlayButton,
          //color: Colors.indigo,
          child: const Text(
            'Play',
            style: TextStyle(color: Colors.black),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
      ]));
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Mozilla Audio Buffer Source Node'),
        actions: const <Widget>[],
      ),
      body: makeBody(),
    );
  }
}
