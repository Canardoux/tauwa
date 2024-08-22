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
class CompressorEx extends StatefulWidget {
  const CompressorEx({super.key});
  @override
  State<CompressorEx> createState() => _CompressorEx();
}

class _CompressorEx extends State<CompressorEx> {
  String pcmAsset = 'assets/wav/viper.ogg'; // The OGG asset to be played

  AudioContext? audioCtx;
  AudioDestinationNode? dest;
  AudioBufferSourceNode? source;
  AudioBuffer? audioBuffer;
  DynamicsCompressorNode? compressor;
  bool playDisabled = false;
  bool stopDisabled = true;
  double pannerValue = 0;
  String path = '';
  bool dataActive = false;

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
    source = audioCtx!.createBufferSource();
    source!.setBuffer(audioBuffer: audioBuffer!);
    dest = audioCtx!.destination();
    compressor = audioCtx!.createDynamicsCompressor();
    compressor!.threshold.value = -50;
    compressor!.knee.value = 40;
    compressor!.ratio.value = 12;
    compressor!.attack.value = 0;
    compressor!.release.value = 0.25;
    source!.connect(dest: dest!);
    source!.start();
    setState(() {});

    Tauwa.tauwa.logger.d('Une bonne journée');
  }



  void removeCompression()  {
    source!.disconnect();
    compressor!.disconnect();
    source!.connect(dest: dest!);
    dataActive = false;
      if (mounted) {
      setState(() {});
    }
  }

  void addCompression()  {

    source!.disconnect();
    source!.connect(dest: compressor!);
    compressor!.connect(dest: dest!);
    dataActive = true;
      if (mounted) {
      setState(() {});
    }
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

            ElevatedButton(
              onPressed: dataActive ? removeCompression : addCompression,
              //color: Colors.indigo,
              child:  Text(
                dataActive ? 'Remove compression' : 'Add compression',
                style: const TextStyle(color: Colors.black),
              ),
            ),

        ]),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Compressor'),
        actions: const <Widget>[],
      ),
      body: makeBody(),
    );
  }
}
