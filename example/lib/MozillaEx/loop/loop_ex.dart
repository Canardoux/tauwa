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
class LoopEx extends StatefulWidget {
  const LoopEx({super.key});
  @override
  State<LoopEx> createState() => _LoopEx();
}

class _LoopEx extends State<LoopEx> {
  String pcmAsset = 'assets/wav/sample2.aac'; // The Wav asset to be played

  AudioContext? audioCtx;
  AudioDestinationNode? dest;
  AudioBufferSourceNode? source;
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
    await loadAudio();
    audioBuffer = audioCtx!.decodeAudioDataSync(inputPath: path);
    double duration = audioBuffer!.duration();
    max = duration; // The value is incorrect !
    setState(() {});

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

    source = audioCtx!.createBufferSource();

    if (audioBuffer!.isDisposed) {
      Tauwa.tauwa.logger.d('Is disposed');
    }
    int n = audioBuffer!.numberOfChannels();
    //var audioBufferCloned = audioBuffer!.clone();
    source!.setBuffer(audioBuffer: audioBuffer!);
    if (audioBuffer!.isDisposed) {
      Tauwa.tauwa.logger.d('Is disposed');
    }

    dest = audioCtx!.destination();
    source!.connect(dest: dest!);
    source!.setLoopStart(value: loopStartValue);
    source!.setLoopEnd(value: loopEndValue);
    source!.setLoop(value: true);

    //source.loopStart = loopstartControl.value;
    //source.loopEnd = loopendControl.value;
    source!.startAtWithOffsetAndDuration(
        start: 0, offset: loopStartValue, duration: loopEndValue);
    playDisabled = true;
    stopDisabled = false;

    /*
    var sampleRate = await audioCtx!.sampleRate();
    var frameCount = (sampleRate * 2.0).ceil();
    List<Float32List> buf = List<Float32List>.filled(
        channels,
        Float32List(
          frameCount,
        ));
    List<Float32List>.filled(channels, Float32List(frameCount));
    src = await audioCtx!.createBufferSource();
    for (int channel = 0; channel < channels; ++channel) {
      Float32List nowBuffering = Float32List(frameCount);
      for (int i = 0; i < frameCount; ++i) {
        double rng = (Random().nextDouble() * 2) - 1;
        nowBuffering[i] = rng;
      }
      buf[channel] = nowBuffering;
    }
    AudioBuffer audioBuffer =
        await AudioBuffer.from(samples: buf, sampleRate: 48000);


    src = await audioCtx!.createBufferSource();
    src!.setBuffer(audioBuffer: audioBuffer);

    dest = await audioCtx!.destination();
    src!.connect(dest: dest!);
    await src!.setOnEnded(callback: finished);
    src!.start();
     */
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> hitStopButton() async {
    source!.stop();
    disposeEverything();
    playDisabled = false;
    stopDisabled = true;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> loopStart(double v) async // v is between 0.0 and max
  {
    loopStartValue = v;
    if (source != null) {
      source!.setLoopStart(value: v);
    }
    setState(() {});
  }

  Future<void> loopEnd(double v) async // v is between 0.0 and max
  {
    loopEndValue = v;
    if (source != null) {
      source!.setLoopEnd(value: v);
    }
    setState(() {});
  }

  Future<void> finished(Event event) async {
    Tauwa.tauwa.logger.d('lolo');
    source!.stop();
    setState(() {});

    Tauwa.tauwa.logger.d('C\'est parti mon kiki');
    setState(() {});
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
          const Text('Start:'),
          Slider(
            value: loopStartValue,
            min: 0.0,
            max: max,
            onChanged: loopStart,
            //divisions: 1
          ),
          const SizedBox(
            height: 20,
          ),
          const Text('End:'),
          Slider(
            value: loopEndValue,
            min: 0.0,
            max: max,
            onChanged: loopEnd,

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
