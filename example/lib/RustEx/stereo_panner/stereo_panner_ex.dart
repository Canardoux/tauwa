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

/*
 *
 * This is a very simple example for Tau beginners,
 * that show how to playback a file.
 *
 * This example is really basic.
 *
 */

import 'package:flutter/material.dart';
import 'dart:async';
//!!!import 'dart:html';
import 'package:tauwa/tauwa.dart';
import 'package:logger/logger.dart' as lg;

// =====================================================================

// ======================================================================
class StereoPanner extends StatefulWidget {
  const StereoPanner({super.key});

  @override
  State<StereoPanner> createState() => _StereoPanner();
}

class _StereoPanner extends State<StereoPanner> {
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Tauwa.tauwa.logger.d('Une bonne journée');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    Tauwa.tauwa.logger.d('Une bonne journée');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      //_platformVersion = platformVersion;
    });
  }

  void rustStereoPanner() async {
    /*
      ====================  The rust code was :  ==================================

    let latency_hint = match std::env::var("WEB_AUDIO_LATENCY").as_deref() {
        Ok("playback") => AudioContextLatencyCategory::Playback,
        _ => AudioContextLatencyCategory::default(),
    };

    let context = AudioContext::new(AudioContextOptions {
        latency_hint,
        ..AudioContextOptions::default()
    });

    // pipe 2 oscillator into two panner, one on each side of the stereo image
    // inverse the direction of the panning every 4 second

    // create a stereo panner
    let panner_1 = context.create_stereo_panner();
    let mut pan_1 = -1.;
    panner_1.set_channel_count(1);
    panner_1.connect(&context.destination());
    panner_1.pan().set_value(pan_1);
    // create an oscillator
    let mut osc_1 = context.create_oscillator();
    osc_1.connect(&panner_1);
    osc_1.frequency().set_value(200.);
    osc_1.start();

    // create a stereo panner for mono input
    let panner_2 = context.create_stereo_panner();
    let mut pan_2 = 1.;
    panner_2.set_channel_count(1);
    panner_2.connect(&context.destination());
    panner_2.pan().set_value(pan_2);
    // create an oscillator
    let mut osc_2 = context.create_oscillator();
    osc_2.connect(&panner_2);
    osc_2.frequency().set_value(300.);
    osc_2.start();

    std::thread::sleep(std::time::Duration::from_secs(4));

    loop {
        // reverse the stereo image
        let now = context.current_time();

        panner_1.pan().set_value_at_time(pan_1, now);
        pan_1 = if pan_1 == 1. { -1. } else { 1. };
        panner_1.pan().linear_ramp_to_value_at_time(pan_1, now + 1.);

        panner_2.pan().set_value_at_time(pan_2, now);
        pan_2 = if pan_2 == 1. { -1. } else { 1. };
        panner_2.pan().linear_ramp_to_value_at_time(pan_2, now + 1.);

        std::thread::sleep(std::time::Duration::from_secs(4));
    }
     */

    // =========================  The dart code is now : ===========================
  }

  void dartStereoPanner() async {
    initPlatformState();
    String s = greet(name: "Tom" /*, hint: 'la plume'*/);
    String s2 = toto();
    Tauwa.tauwa.logger.d(s2);
    String s3 = zozo();
    Tauwa.tauwa.logger.d(s3);
    //int sumResult = sum(1, 2);
    //Tauwa.tauwa.logger.i("Add 1 to 2 gives $sumResult");
    Tauwa.tauwa.logger.i(s);
    Tauwa().setLogLevel(lg.Level.debug);
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
          onPressed: rustStereoPanner,
          //color: Colors.indigo,
          child: const Text(
            'Play Rust',
            style: TextStyle(color: Colors.black),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        ElevatedButton(
          onPressed: dartStereoPanner,
          //color: Colors.indigo,
          child: const Text(
            'Play Dart',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ]));
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Rust Stereo Panner'),
      ),
      body: makeBody(),
    );
  }
}
