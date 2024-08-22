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

const pcmAsset = 'assets/wav/outfoxing.mp3'; // The Raw PCM asset to be played


const filterNumber = 2;
var feedForward = feedforward[filterNumber];
var feedBack = feedback[filterNumber];

const feedforward =
[
  [0.00020298, 0.0004059599, 0.00020298],
  [0.0012681742, 0.0025363483, 0.0012681742],
  [0.0050662636, 0.0101325272, 0.0050662636],
  [0.1215955842, 0.2431911684, 0.1215955842],
  ];

const feedback =
[
  [1.0126964558, -1.9991880801, 0.9873035442],
  [1.0317185917, -1.9949273033, 0.9682814083],
  [1.0632762845, -1.9797349456, 0.9367237155],
  [1.2912769759, -1.5136176632, 0.7087230241],
];

/****
const frequency =
[
  200, 500, 1000, 5000
  ];
****/



/// This is a very simple example for τ beginners, that show how to playback a file.
/// Its a translation to Dart from [Mozilla example](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Using_Web_Audio_API)
/// This example is really basic.
class IirFilterNodeEx extends StatefulWidget {
  const IirFilterNodeEx({super.key});
  @override
  State<IirFilterNodeEx> createState() => _IirFilterNodeEx();
}

class _IirFilterNodeEx extends State<IirFilterNodeEx> {
  late AudioContext audioCtx;
  late AudioDestinationNode dest;
  late IirFilterNode iirFilter;
   AudioBufferSourceNode? srcNode;
  late AudioBuffer audioBuffer;
  //late Float32List sample;
  bool isFiltered = false;

  var path = '';



  Future<void> loadAudio() async {
    var asset = await rootBundle.load(pcmAsset);

    var tempDir = await getTemporaryDirectory();
    path = '${tempDir.path}/tau.mp3';
    var file = File(path);
    file.writeAsBytesSync(asset.buffer.asInt8List());
    //sample = asset.buffer.asFloat32List();
    audioBuffer = audioCtx.decodeAudioDataSync(inputPath: path); // VERY LONG!!!!!
    //sample = audioBuffer.getChannelData(channelNumber: 0);
  }

  // And here is our dart code
  Future<void> initPlatformState() async {

    audioCtx = AudioContext(
        options: const AudioContextOptions(
      latencyHint: AudioContextLatencyCategory.playback(),
      sinkId: '',
      renderSizeHint: AudioContextRenderSizeCategory.default_,
      //sampleRate: 44100,
    ));
    await loadAudio();
    dest = audioCtx.destination();
    iirFilter = audioCtx.createIirFilter(feedforward: feedforward[filterNumber], feedback: feedback[filterNumber]);

    /*****
// Arrays for the frequency response
    const totalArrayItems = 30;

// We need to create arrays that return the data,
// these need to be the same size as the origianl frequency array
    var magResponseOutput = Float32List(totalArrayItems);
    var phaseResponseOutput = Float32List(totalArrayItems);


// Create an array of frequency values that we would like to get data about.
// We could go for a linear approach, but it's far better when working
// with frequencies to take a log approach, so let's fill our array with frequencies
// that get larger as array item goes up.
    var myFrequencyArray = Float32List(totalArrayItems);
    for (int i = 0; i < totalArrayItems; ++i)
      {
        myFrequencyArray[i] = Math.pow(1.4, i);
      }

    // Get frequency response
    iirFilter.getFrequencyResponse(
    myFrequencyArray,
    magResponseOutput,
    phaseResponseOutput
    );
        ****/

    setState(() {});

    //Tau.tau.logger.d('Une bonne journée');
  }

  bool isPlaying = false;
  Future<void> finished(Event event) async {
    Tauwa.tauwa.logger.d('lolo');
    //audioCtx.close();
    isPlaying = false;
    setState(() {});
  }

  AudioBufferSourceNode playSourceNode(audioContext, audioBuffer) {
    AudioBufferSourceNode soundSource = audioCtx.createBufferSource();
    soundSource.setBuffer(audioBuffer: audioBuffer!);

    soundSource.connect(dest: dest);
    soundSource.start();
    soundSource.setOnEnded(callback: finished);
    return soundSource;
  }

  Future<void> hitPlayButton() async {
    AudioContextState state = audioCtx.state();

    if (!isPlaying) {
      // Check if context is in suspended state (autoplay policy)
      if (state == AudioContextState.suspended) {
        audioCtx.resumeSync();
      }
      if (srcNode != null)
        {
          srcNode!.dispose();
        }
      srcNode = playSourceNode(audioCtx, audioBuffer);
      isPlaying = true;
    } else {
      srcNode!.stop();
      isPlaying = false;
    }

    Tauwa.tauwa.logger.d('C\'est parti mon kiki');
    setState(() {});
  }

  void filterChanged(bool value)
  {
    if (value) {
      srcNode!.disconnect();
      srcNode!.connect(dest: iirFilter);
      iirFilter.connect(dest: dest);
    } else {
      srcNode!.disconnect();
      srcNode!.connect(dest: dest);
    }

  }

  // Good citizens must dispose nodes and Audio Context
  @override
  void dispose() {
    Tauwa.tauwa.logger.d("dispose");
    audioCtx.close();
    audioCtx.dispose();
    dest.dispose();
    if (srcNode != null)
    {
      srcNode!.dispose();
    }

    super.dispose();
  }

  @override
  void initState()  {
    //initPlatformState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: hitPlayButton,
              //color: Colors.indigo,
              child: const Text(
                'Play',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(
              width: 60,
            ),
            const Text("Filter"),
            Switch(
              // This bool value toggles the switch.
              value: isFiltered,
              activeColor: Colors.red,
              onChanged: (bool value) {
                // This is called when the user toggles the switch.
                filterChanged(value);
                setState(() {
                  isFiltered = value;
                });
              },
            )
          ]),
          SizedBox(
            width: 500,
            height: 250,
            child: Text('toto')
             ),

        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Mozilla IIR Filter Node'),
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
    <title>Web Audio API examples: IIR Filter</title>
    <meta name="description" content="IIR Filter Demo for Web Audio API" />
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

        --border: 5px solid var(--black);
        --borderRad: 2px;
      }
      * {
        box-sizing: border-box;
      }

      body {
        margin: 0;
        background-color: var(--white);
        font-family: system-ui;
        color: var(--black);
      }

      .wrapper {
        position: relative;
        display: flex;
        flex-direction: column;
        align-items: center;
      }

      .loading {
        background: white;
        position: absolute;
        left: 0;
        right: 0;
        height: 100vh;
        z-index: 2;
        display: flex;
        justify-content: center;
        align-items: center;
      }

      .loading p {
        font-size: 200%;
        text-align: center;
        animation: loading ease-in-out 2s infinite;
      }

      @keyframes loading {
        0% {
          opacity: 0;
        }
        50% {
          opacity: 1;
        }
        100% {
          opacity: 0;
        }
      }

      .iir-demo {
        text-align: center;
      }

      /* play button */
      button,
      span {
        font-size: 120%;
      }
      [class^="button"] {
        cursor: pointer;
      }
      .button-play {
        background-color: var(--orange);
        display: block;
        margin: 3rem auto;
        padding: 3vmin 4vmin 3vmin 12vmin;
        border: var(--border);
        border-radius: var(--borderRad);
      }

      [data-playing="false"] {
        background: var(--red)
          url('data:image/svg+xml;charset=utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512"><path d="M424.4 214.7L72.4 6.6C43.8-10.3 0 6.1 0 47.9V464c0 37.5 40.7 60.1 72.4 41.3l352-208c31.4-18.5 31.5-64.1 0-82.6z" fill="black" /></svg>')
          no-repeat left center;
        background-size: 60% 60%;
        cursor: pointer;
      }

      [data-playing]:hover {
        background-color: var(--orange);
      }

      [data-playing="true"] {
        background: var(--green)
          url('data:image/svg+xml;charset=utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512"><path d="M144 479H48c-26.5 0-48-21.5-48-48V79c0-26.5 21.5-48 48-48h96c26.5 0 48 21.5 48 48v352c0 26.5-21.5 48-48 48zm304-48V79c0-26.5-21.5-48-48-48h-96c-26.5 0-48 21.5-48 48v352c0 26.5 21.5 48 48 48h96c26.5 0 48-21.5 48-48z" fill="black" /></svg>')
          no-repeat left center;
        background-size: 60% 60%;
      }

      /* filter button */
      .filter-toggle {
        margin: 4vmin auto;
      }

      .button-filter {
        margin: 0px 0px 0px 10px;
        padding: 0;
        width: 90px;
        height: 50px;
        display: inline-block;
        vertical-align: middle;
        border: var(--border);
        border-radius: 25px;
        position: relative;
        text-align: center;
        transition: background 0.15s ease-in-out;
      }

      .button-filter:after {
        content: "";
        position: absolute;
        height: 31px;
        width: 31px;
        border: var(--border);
        border-radius: 50%;
        background-color: var(--red);
        top: 0px;
        transition: left 0.15s ease-in-out;
        will-change: left;
      }

      .button-filter[data-filteron="true"]:after {
        background-color: var(--green);
        left: 0px;
      }

      .button-filter[disabled] {
        cursor: default;
        border-color: hsla(0, 0%, 40%, 1);
      }

      .button-filter[disabled]:after {
        background-color: hsla(342, 93%, 73%, 1);
        border-color: hsla(0, 0%, 40%, 1);
      }

      .button-filter[data-filteron="true"][disabled]:after {
        background-color: hsla(127, 81%, 61%, 1);
      }

      .filter-graph {
        margin-top: 20px;
        width: 60vw;
        height: 40vw;
        max-width: 600px;
        max-height: 400px;
      }
    </style>
  </head>
  <body>
    <div class="wrapper">
      <div class="loading">
        <p>Loading...</p>
      </div>

      <div class="iir-demo">



        <section class="filter-graph"></section>
      </div>
    </div>

    <script>
      console.clear();

      // Create the audio context
      const audioCtx = new AudioContext();

      // Fetch the audio file and decode the data
      async function getFile(audioContext, filepath) {
        const response = await fetch(filepath);
        const arrayBuffer = await response.arrayBuffer();
        const audioBuffer = await audioContext.decodeAudioData(arrayBuffer);
        return audioBuffer;
      }
      // Create a buffer, plop in data, connect and play -> modify graph here if required
      function playSourceNode(audioContext, audioBuffer) {
        const soundSource = new AudioBufferSourceNode(audioContext, {
          buffer: audioBuffer,
        });
        soundSource.connect(audioContext.destination);
        soundSource.start();
        return soundSource;
      }

      async function setupSample() {
        const filePath = "outfoxing.mp3";
        // Here we're `await`ing the async/promise that is `getFile`.
        // To be able to use this keyword we need to be within an `async` function
        sample = await getFile(audioCtx, filePath);
        return sample;
      }

      // Change this to change the filter - can be 0-3 and will reference the values in the array below
      const filterNumber = 2;

      const lowPassCoefs = [
        {
          frequency: 200,
          feedforward: [0.00020298, 0.0004059599, 0.00020298],
          feedback: [1.0126964558, -1.9991880801, 0.9873035442],
        },
        {
          frequency: 500,
          feedforward: [0.0012681742, 0.0025363483, 0.0012681742],
          feedback: [1.0317185917, -1.9949273033, 0.9682814083],
        },
        {
          frequency: 1000,
          feedforward: [0.0050662636, 0.0101325272, 0.0050662636],
          feedback: [1.0632762845, -1.9797349456, 0.9367237155],
        },
        {
          frequency: 5000,
          feedforward: [0.1215955842, 0.2431911684, 0.1215955842],
          feedback: [1.2912769759, -1.5136176632, 0.7087230241],
        },
      ];

      const feedForward = lowPassCoefs[filterNumber].feedforward;
      const feedBack = lowPassCoefs[filterNumber].feedback;

      // Create a canvas element and append it to our dom
      const canvasContainer = document.querySelector(".filter-graph");
      const canvasEl = document.createElement("canvas");
      canvasContainer.appendChild(canvasEl);

      // Set 2d context and dimensions
      const canvasCtx = canvasEl.getContext("2d");
      const width = canvasContainer.offsetWidth;
      const height = 200; //!!!!!canvasContainer.offsetHeight;
      canvasEl.width = width;
      canvasEl.height = height;

      // Set fill and create axis
      canvasCtx.fillStyle = "white";
      canvasCtx.fillRect(0, 0, width, height);

      const spacing = width / 16;
      const fontSize = Math.floor(spacing / 1.5);
      canvasCtx.lineWidth = 2;
      canvasCtx.strokeStyle = "grey";

      // Draw axis
      canvasCtx.beginPath();
      canvasCtx.moveTo(spacing, spacing);
      canvasCtx.lineTo(spacing, height - spacing);
      canvasCtx.lineTo(width - spacing, height - spacing);
      canvasCtx.stroke();
      // Axis is gain by frequency
      canvasCtx.font = `10px sans-serif`;
      canvasCtx.fillStyle = "grey";
      canvasCtx.fillText("1", spacing - fontSize, spacing + fontSize);
      canvasCtx.fillText(
        "g",
        spacing - fontSize,
        (height - spacing + fontSize) / 2
      );
      canvasCtx.fillText("0", spacing - fontSize, height - spacing + fontSize);
      canvasCtx.fillText("Hz", width / 2, height - spacing + fontSize);
      canvasCtx.fillText("20k", width - spacing, height - spacing + fontSize);

      // DOM elements needed
      const loadingSection = document.querySelector(".loading");
      const playButton = document.querySelector(".button-play");
      const filterButton = document.querySelector(".button-filter");

      // Arrays for the frequency response
      const totalArrayItems = 30;

      // Create an array of frequency values that we would like to get data about.
      // We could go for a linear approach, but it's far better when working
      // with frequencies to take a log approach, so let's fill our array with frequencies
      // that get larger as array item goes up.
      let myFrequencyArray = new Float32Array(totalArrayItems);
      myFrequencyArray = myFrequencyArray.map((item, index) => {
        return Math.pow(1.4, index);
      });

      // We need to create arrays that return the data,
      // these need to be the same size as the origianl frequency array
      let magResponseOutput = new Float32Array(totalArrayItems);
      let phaseResponseOutput = new Float32Array(totalArrayItems);

      // Let the magic happen! When the file has loaded...
      //!!!!!!setupSample().then((sample) => {
        // Remove loading screen
        loadingSection.style.display = "none";

        // Create the iir filter
        const iirfilter = new IIRFilterNode(audioCtx, {
          feedforward: feedForward,
          feedback: feedBack,
        });

        let srcNode;
        // Play/pause the track


        // Get frequency response
        iirfilter.getFrequencyResponse(
          myFrequencyArray,
          magResponseOutput,
          phaseResponseOutput
        );

        // Draw graph
        canvasCtx.beginPath();
        for (let i = 0; i < magResponseOutput.length; i++) {
          if (i === 0) {
            canvasCtx.moveTo(
              spacing,
              height - magResponseOutput[i] * (height - spacing * 2) - spacing
            );
          } else {
            canvasCtx.lineTo(
              (width / totalArrayItems) * i,
              height - magResponseOutput[i] * (height - spacing * 2) - spacing
            );
          }
        }
        canvasCtx.stroke();
      //!!!!});
    </script>
  </body>
</html>


''';
}
