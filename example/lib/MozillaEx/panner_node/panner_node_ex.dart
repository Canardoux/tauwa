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
class PannerNodeEx extends StatefulWidget {
  const PannerNodeEx({super.key});
  @override
  State<PannerNodeEx> createState() => _PannerNodeEx();
}

class _PannerNodeEx extends State<PannerNodeEx> {
  String pcmAsset = 'assets/wav/viper.ogg'; // The OGG asset to be played

  AudioContext? audioCtx;
  AudioDestinationNode? dest;
  AudioBufferSourceNode? source;
  AudioBuffer? audioBuffer;
  PannerNode? panner;
  final channels = 1;
  bool playDisabled = false;
  bool stopDisabled = true;
  var path = '';
  AudioListener? listener;


double xPos = 200;
double yPos = 200;
double zPos = 295;

double boomX = 0;
double boomY = 0;
double boomZoom = 10;
double xIterator = 10;
double leftBound = -200 + 50;
double  rightBound =200 - 50;

  Future<void> loadAudio() async {
    var asset = await rootBundle.load(pcmAsset);

    var tempDir = await getTemporaryDirectory();
    path = '${tempDir.path}/tau.ogg';
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

  panner = audioCtx!.createPanner();
  panner!.setPanningModel( value: PanningModelType.hrtf);
    panner!.setDistanceModel(value: DistanceModelType.inverse);
    panner!.setRefDistance(value: 1);
    panner!.setMaxDistance(value: 10000);
    panner!.setRolloffFactor(value: 1);
    panner!.setConeInnerAngle(value: 360);
    panner!.setConeOuterAngle(value: 0);
    panner!.setConeOuterGain(value: 0);
    panner!.setOrientation(x: 1, y: 0, z: 0);

    listener = audioCtx!.listener();

      // Standard way
      listener!.forwardX.value = 0;
      listener!.forwardY.value = 0;
      listener!.forwardZ.value = -1;
      listener!.upX.value = 0;
      listener!.upY.value = 1;
      listener!.upZ.value = 0;

    setState(() {});

    Tauwa.tauwa.logger.d('Une bonne journée');
  }

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

    playDisabled = true;
    stopDisabled = false;
    source!.start();

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

  // panner will move as the boombox graphic moves around on the screen
  void positionPanner() {
    panner!.positionX.value = xPos;
    panner!.positionY.value = yPos;
    panner!.positionZ.value = zPos;
  }


  void moveZoomIn()
  {
   boomZoom += 1;
    zPos += 0.6;

    if (boomZoom > 4) {
      boomZoom = 4;
      zPos = 299.9;
    }

    positionPanner();

  }
  void moveZoomOut()
  {
    boomZoom += -1;
    zPos += -0.6;

    if (boomZoom <= 0.5) {
      boomZoom = 0.5;
      zPos = 295;
    }

    positionPanner();

  }
  void left()
  {
   boomX += xIterator;
    xPos += 10;

    if (boomX > rightBound) {
      boomX = rightBound;
      xPos = 400 / 2 + 5;
    }

    positionPanner();

  }
  void right()
  {
    boomX += -xIterator;
    xPos += -10;

    if (boomX <= leftBound) {
      boomX = leftBound;
      xPos = 400 / 2 - 5;
    }

    positionPanner();

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

         //Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: moveZoomIn,
              //color: Colors.indigo,
              child: const Text(
                'move zoom-in',
                style: TextStyle(color: Colors.black),
              ),
            ),

         const SizedBox(
            height: 20,

          ),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: left,
              //color: Colors.indigo,
              child: const Text(
                'left',
                style: TextStyle(color: Colors.black),
              ),
            ),

         const SizedBox(
            height: 20,

          ),
           ElevatedButton(
              onPressed: right,
              //color: Colors.indigo,
              child: const Text(
                'right',
                style: TextStyle(color: Colors.black),
              ),
            ),
      ]),

          const SizedBox(
            height: 20,

          ),

            ElevatedButton(
              onPressed:  moveZoomOut,
              //color: Colors.indigo,
              child: const Text(
                'move zoom-out',
                style: TextStyle(color: Colors.black),
              ),
            ),


      ]));

    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Mozilla Audio Panner'),
        actions: const <Widget>[],
      ),
      body: makeBody(),
    );
  }
}
