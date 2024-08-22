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
// For call to setLogLevel()
//import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tauwa/tauwa.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

const pcmAsset =
    'assets/samples-f32/sample-f32-48000-32kb_s.pcm'; // The Raw PCM asset to be played

/// This is a very simple example for τ beginners, that show how to playback a file.
/// Its a translation to Dart from [Mozilla example](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Using_Web_Audio_API)
/// This example is really basic.
class MultiTrackEx extends StatefulWidget {
  const MultiTrackEx({super.key});
  @override
  State<MultiTrackEx> createState() => _MultiTrackEx();
}

class _MultiTrackEx extends State<MultiTrackEx> {
  late AudioContext audioCtx;
  late AudioDestinationNode dest;
  List<AudioBuffer> audioBuffers = [];
  List<AudioBufferSourceNode> audioBufferSourceNodes = [];

  void initPlatformState() async {
    audioCtx = AudioContext(
        options: const AudioContextOptions(
      latencyHint: AudioContextLatencyCategory.playback(),
      sinkId: '',
      renderSizeHint: AudioContextRenderSizeCategory.default_,
      sampleRate: 48000,
    ));

    dest = audioCtx.destination();
  }

  // And here is our dart code
 double offset = 0;
  Future<void> playTrack(int index) async {
    AudioBufferSourceNode source = audioCtx.createBufferSource();
    audioBufferSourceNodes.add(source);

    source.setBuffer(audioBuffer: audioBuffers[index]);

    source.connect(dest: dest);
    if (offset == 0) {
      source.start();
      offset = audioCtx.currentTime();
    } else {
      source.startAtWithOffset(start: 0, offset: audioCtx.currentTime() - offset);
    }


  }

  AudioBuffer getBuffer (String inputPath)
  {
    AudioBuffer myBuffer = audioCtx.decodeAudioDataSync(inputPath: inputPath);
    return myBuffer;
  }

  Future<AudioBuffer> loadFile(String file) async {
    Tauwa.tauwa.logger.d(file);
    var asset = await rootBundle.load('assets/wav/$file');

    var tempDir = await getTemporaryDirectory();
    var path = '${tempDir.path}/$file';
    var f = File(path);
    f.writeAsBytesSync(asset.buffer.asInt8List());
    AudioBuffer buf = getBuffer(path);
    if (buf.isDisposed)
      {
        print ('Buf is an invalid dart object');
      }
    //audioBuffer = audioCtx.decodeAudioDataSync(inputPath: path);
    return buf;
  }

  // Good citizens must dispose nodes and Audio Context
  @override
  void dispose() {
    Tauwa.tauwa.logger.d("dispose");
    audioCtx.close();
    audioCtx.dispose();
    dest.dispose();
    for (int i = 0; i < audioBuffers.length; ++i)
    {
      audioBuffers[i].dispose();
    }
    for (int i = 0; i < audioBufferSourceNodes.length; ++i)
    {
      audioBufferSourceNodes[i].dispose();
    }

    super.dispose();
  }

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Text('toto'
      );

    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Mozilla Multi Track'),
        actions: const <Widget>[],
      ),
      body: makeBody(),
    );
  }

  final String _htmlData = '''

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Web Audio API examples: Loading audio files</title>
    <meta
      name="description"
      content="A way to make sure files have loaded before playing them"
    />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1, shrink-to-fit=no"
    />
   <style>
   :root {
  --orange: hsla(32, 100%, 50%, 1);
  --yellow: hsla(49, 99%, 50%, 1);
  --lime: hsla(82, 90%, 45%, 1);
  --green: hsla(127, 81%, 41%, 1);
  --red: hsla(342, 93%, 53%, 1);
  --pink: hsla(314, 85%, 45%, 1);
  --blue: hsla(211, 92%, 52%, 1);
  --purple: hsla(283, 92%, 44%, 1);
  --cyan: hsla(195, 98%, 55%, 1);
  --white: hsla(0, 0%, 95%, 1);
  --black: hsla(0, 0%, 10%, 1);

  /* abstract our colours */
  --boxMain: var(--cyan);
  --boxSecond: var(--blue);
  --boxHigh: var(--yellow);
  --border: 1vmin solid var(--black);
  --borderRad: 2px;
}

* {
  box-sizing: border-box;
}

body {
  background-color: var(--white);
  padding: 4vmax;
  font-family: sans-serif, system-ui;
  font-size: 60%;
  color: var(--black);
}

#startbutton {
  width: 12vw;
  line-height: 3;
  background-color: var(--boxMain);
  border: var(--border);
  border-radius: var(--borderRad);
  position: absolute;
  top: 1px;
  left: 1px;
}

#startbutton:hover {
  background-color: var(--boxSecond);
}

.wrapper {
  display: flex;
  justify-content: center;
  align-items: center;
}

#tracks {
}
#tracks ul {
  list-style: none;
  margin: 0px;
  padding: 0px;
  width: 62vw;
  background-color: var(--boxMain);
  border: var(--border);
  border-radius: var(--borderRad);
}
#tracks li {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 2vw;
  border-bottom: var(--border);
}
#tracks li:last-child {
  border-bottom: none;
}
#tracks li[data-loading="true"] {
  background-color: var(--boxHigh);
}

.loading-text,
.track,
.playbutton {
}

.loading-text {
}
.track {
  color: var(--black);
}
.track:hover {
  text-decoration: none;
}

.playbutton {
  display: none;
  padding: 3px;
  border: var(--border);
  border-radius: var(--borderRad);
  font-size: 40%;
  cursor: pointer;
}
.playbutton span {
  display: none;
}
[data-playing] {
  background: var(--red)
    url('data:image/svg+xml;charset=utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512"><path d="M424.4 214.7L72.4 6.6C43.8-10.3 0 6.1 0 47.9V464c0 37.5 40.7 60.1 72.4 41.3l352-208c31.4-18.5 31.5-64.1 0-82.6z" fill="black" /></svg>')
    no-repeat center center;
  background-size: 60% 60%;
}
[data-playing]:hover,
[data-playing="true"] {
  background-color: var(--green);
}

.sourced {
  font-size: 86%;
  text-align: right;
}

</style>
  </head>
  <body>
    <!--
       Some browsers' autoplay policy requires that an AudioContext be initialized
       during an input event in order to correctly synchronize.

       So provide a simple button to get things started.
  -->
    <button id="startbutton" onclick="runButton()">Press to load tracks</button>

    <div class="wrapper">
      <section id="tracks">
        <ul>
          <li data-loading="true">
            <a href="leadguitar.mp3" class="track">Lead Guitar</a>
            <button
              data-playing="false"
              aria-decribedby="guitar-play-label"
              class="playbutton"
            >
              <span id="guitar-play-label">Play</span>
            </button>
          </li>
          <li data-loading="true">
            <a href="bassguitar.mp3" class="track">Bass Guitar</a>
            <button
              data-playing="false"
              aria-describedby="bass-play-label"
              class="playbutton"
            >
              <span id="bass-play-label">Play</span>
            </button>
          </li>
          <li data-loading="true">
            <a href="drums.mp3" class="track">Drums</a>
            <button
              data-playing="false"
              aria-describedby="drums-play-label"
              class="playbutton"
            >
              <span id="drums-play-label">Play</span>
            </button>
          </li>
          <li data-loading="true">
            <a href="horns.mp3" class="track">Horns</a>
            <button
              data-playing="false"
              aria-describedby="horns-play-label"
              class="playbutton"
            >
              <span id="horns-play-label">Play</span>
            </button>
          </li>
          <li data-loading="true">
            <a href="clav.mp3" class="track">Clavi</a>
            <button
              data-playing="false"
              aria-describedby="clavi-play-label"
              class="playbutton"
            >
              <span id="clavi-play-label">Play</span>
            </button>
          </li>
        </ul>
        <p class="sourced">
          All tracks sourced from <a href="http://jplayer.org/">jplayer.org</a>
        </p>
      </section>
    </div>
    <!-- wrapper -->

    <script type="text/javascript">
      console.clear();
      const startButton = document.querySelector("#startbutton");
      console.log(startButton);

      // Select all list elements
      const trackEls = document.querySelectorAll("li");
      console.log(trackEls);


      function runButton()
      {
        console.log('runButton()');
         document.querySelector("#startbutton").hidden = true;

        trackEls.forEach((el, i) => {
          // Get children
          console.log('For Each');
          const anchor = el.querySelector("a");
          const loadText = el.querySelector("p");
          const playButton = el.querySelector(".playbutton");
          console.log(anchor.href);
          // Load file
           window.flutter_inappwebview.callHandler('loadFile', anchor.href).then((track) => {
            console.log('zaza');
            //el.dataset.loading = "false";
            console.log('toto');

            // Hide loading text
            //loadText.style.display = "none";
            console.log('titi');

            // Show button
            playButton.style.display = "inline-block";
            console.log('zozo');

            // Allow play on click
            console.log('track');
            playButton.addEventListener("click", () => {
            console.log('click');
            console.log(track);
            window.flutter_inappwebview.callHandler('playTrack', track);
              // check if context is in suspended state (autoplay policy)
              playButton.dataset.playing = true;
            });
          });
        });

      }

    </script>
  </body>
</html>

''';
}
