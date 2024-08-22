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
    'assets/wav/dtmf.mp3'; // The Raw PCM asset to be played

/// This is a very simple example for τ beginners, that show how to playback a file.
/// Its a translation to Dart from [Mozilla example](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Using_Web_Audio_API)
/// This example is really basic.
class StepSequencerEx extends StatefulWidget {
  const StepSequencerEx({super.key});
  @override
  State<StepSequencerEx> createState() => _StepSequencerEx();
}

class _StepSequencerEx extends State<StepSequencerEx> {
  late AudioContext audioCtx;
  late AudioDestinationNode dest;
  late GainNode gainNode;
  late StereoPannerNode panner;
  late AudioBufferSourceNode src;
  AudioBuffer? audioBuffer;
  String path = '';
  // Scheduling
  var tempo = 60.0;

  // Loading the file: fetch the audio file and decode the data

  Future<AudioBuffer> setupSample() async {
    await loadAudio();
    audioBuffer = audioCtx.decodeAudioDataSync(inputPath: path);

    return audioBuffer!;
  }



  Future<void> loadAudio() async {
    var asset = await rootBundle.load(pcmAsset);

    var tempDir = await getTemporaryDirectory();
    path = '${tempDir.path}/tau.mp3';
    var file = File(path);
    file.writeAsBytesSync(asset.buffer.asInt8List());
  }



  // And here is our dart code
  void initPlatformState() async {
    audioCtx = AudioContext(
        options: const AudioContextOptions(
      latencyHint: AudioContextLatencyCategory.playback(),
      sinkId: '',
      renderSizeHint: AudioContextRenderSizeCategory.default_,
      sampleRate: 48000,
    ));



    Tauwa.tauwa.logger.d('Une bonne journée');

    src = audioCtx.createBufferSource();
    src.setBuffer(audioBuffer: audioBuffer!);
    audioBuffer!.dispose();
    dest = audioCtx.destination();
    gainNode = audioCtx.createGain();
    panner = audioCtx.createStereoPanner();

    src.connect(dest: gainNode);
    gainNode.connect(dest: panner);
    panner.connect(dest: dest);
    src.setOnEnded(callback: finished);

    if (mounted) {
      setState(() {});
    }
  }

  bool isPlaying = false;
  bool isStarted = false;
  Future<void> finished(Event event) async {
    Tauwa.tauwa.logger.d('lolo');
    src.stop();
    audioCtx.close();
    isPlaying = false;
    isStarted = false;
    setState(() {});
  }

  Future<void> hitPlayButton() async {
    if (!isStarted) {
      src.start();
      isStarted = true;
      isPlaying = true;
      return;
    }

    AudioContextState state = audioCtx.state();
    if (state == AudioContextState.suspended) {
      audioCtx.resumeSync();
    }
    if (!isPlaying) {
      audioCtx.resumeSync();
      isPlaying = true;
    } else if (isPlaying) {
      audioCtx.suspend();
      isPlaying = false;
    }

    Tauwa.tauwa.logger.d('C\'est parti mon kiki');
    setState(() {});
  }

  // Good citizens must dispose nodes and Auddio Context
  @override
  void dispose() {
    Tauwa.tauwa.logger.d("dispose");
    audioCtx.dispose();
    dest.dispose();
    gainNode.dispose();
    panner.dispose();
    src.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

/*********************************************************************************
  // Create a buffer, plop in data, connect and play -> modify graph here if required
  AudioBufferSourceNode playSample( audioBuffer, time) {
    var sampleSource = audioCtx.createAudioBufferSourceNode(  {
      buffer: audioBuffer,
      playbackRate: playbackRate,
    });
    sampleSource.connect(dest: dest);
    sampleSource.start(time);
    return sampleSource;
  }



  void playNoise(time) {
    var bufferSize = audioCtx.sampleRate() * noiseDuration; // set the time of the note

    // Create an empty buffer
    var noiseBuffer = AudioBuffer({
      length: bufferSize,
      sampleRate: audioCtx.sampleRate,
    });

    // Fill the buffer with noise
    const data = noiseBuffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) {
      data[i] = Math.random() * 2 - 1;
    }

    // Create a buffer source for our created data
    var noise = audioCtx.createAudioBufferSourceNode {
      buffer: noiseBuffer,
    });

    // Filter the output
    var bandpass = audioCtx.createBiquadFilter( {
      type: "bandpass",
      frequency: bandHz,
    });

    // Connect our graph
    noise.connect(dest: bandpass);
    bandpass.connect(dest: dest);
    noise.start(time);
  }

  // Expose attack time & release time
  const sweepLength = 2;
  void playSweep(time) {
    var osc = audioCtx.createOscillator(), {
      frequency: 380,
      type: "custom",
      periodicWave: wave,
    });

    const sweepEnv = audioCtx.createGainNode;
    sweepEnv.gain.cancelScheduledValues(time);
    sweepEnv.gain.setValueAtTime(0, time);
    sweepEnv.gain.linearRampToValueAtTime(1, time + attackTime);
    sweepEnv.gain.linearRampToValueAtTime(
        0,
        time + sweepLength - releaseTime
    );

    osc.connect(sweepEnv).connect(audioCtx.destination);
    osc.start(time);
    osc.stop(time + sweepLength);
  }

  const pulseTime = 1;
  void playPulse(time) {
    const osc = new OscillatorNode(audioCtx, {
      type: "sine",
      frequency: pulseHz,
    });

    const amp = new GainNode(audioCtx, {
      value: 1,
    });

    const lfo = new OscillatorNode(audioCtx, {
      type: "square",
      frequency: lfoHz,
    });

    lfo.connect(amp.gain);
    osc.connect(amp).connect(audioCtx.destination);
    lfo.start();
    osc.start(time);
    osc.stop(time + pulseTime);
  }

  const lookahead = 25.0; // How frequently to call scheduling function (in milliseconds)
  const scheduleAheadTime = 0.1; // How far ahead to schedule audio (sec)

  let currentNote = 0; // The note we are currently playing
  let nextNoteTime = 0.0; // when the next note is due.
  function nextNote() {
    const secondsPerBeat = 60.0 / tempo;

    nextNoteTime += secondsPerBeat; // Add beat length to last beat time

    // Advance the beat number, wrap to zero when reaching 4
    currentNote = (currentNote + 1) % 4;
  }

  // Create a queue for the notes that are to be played, with the current time that we want them to play:
  const notesInQueue = [];
  let dtmf;

  function scheduleNote(beatNumber, time) {
    // Push the note into the queue, even if we're not playing.
    notesInQueue.push({ note: beatNumber, time: time });

    if (pads[0].querySelectorAll("input")[beatNumber].checked) {
      playSweep(time);
    }
    if (pads[1].querySelectorAll("input")[beatNumber].checked) {
      playPulse(time);
    }
    if (pads[2].querySelectorAll("input")[beatNumber].checked) {
      playNoise(time);
    }
    if (pads[3].querySelectorAll("input")[beatNumber].checked) {
      playSample(audioCtx, dtmf, time);
    }
  }

  let timerID;
  void scheduler() {
    // While there are notes that will need to play before the next interval,
    // schedule them and advance the pointer.
    while (nextNoteTime < audioCtx.currentTime + scheduleAheadTime) {
      scheduleNote(currentNote, nextNoteTime);
      nextNote();
    }
    timerID = setTimeout(scheduler, lookahead);
  }

  // Draw function to update the UI, so we can see when the beat progress.
  // This is a loop: it reschedules itself to redraw at the end.
  let lastNoteDrawn = 3;
  void draw() {
    let drawNote = lastNoteDrawn;
    const currentTime = audioCtx.currentTime;

    while (notesInQueue.length && notesInQueue[0].time < currentTime) {
      drawNote = notesInQueue[0].note;
      notesInQueue.shift(); // Remove note from queue
    }

    // We only need to draw if the note has moved.
    if (lastNoteDrawn !== drawNote) {
      pads.forEach((pad) => {
      pad.children[lastNoteDrawn * 2].style.borderColor = "var(--black)";
          pad.children[drawNote * 2].style.borderColor = "var(--yellow)";
      });

      lastNoteDrawn = drawNote;
    }
    // Set up to draw again
    setState(() {});
  }

  map playButton(args)
  {
    isPlaying = !isPlaying;

    if (isPlaying) {
      // Start playing

      // Check if context is in suspended state (autoplay policy)
      if (audioCtx.state == AudioContextState.suspended) {
        audioCtx.resumeSync();
      }

      currentNote = 0;
      nextNoteTime = audioCtx.currentTime;
      scheduler(); // kick off scheduling
      setState(() {

      });; // start the drawing loop.
      ev.target.dataset.playing = "true";
    } else {
      window.clearTimeout(timerID);
      ev.target.dataset.playing = "false";
    }
    // print arguments coming from the JavaScript side!
    Tau.tau.logger.d(args[0]);

    // return data to the JavaScript side!
    return {'bar': 'bar_value', 'baz': 'baz_value'};

  }
***********************************/
  @override
  Widget build(BuildContext context) {

     Widget makeBody() {
      return Text('toto');


      
    }



    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Mozilla Audio Basics'),
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
    <title>Step Sequencer: MDModemnz</title>
    <meta
      name="description"
      content="Making an instrument with the Web Audio API" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <link rel="stylesheet" type="text/css" href="style.css" />

</head>


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
  --boxMain: var(--pink);
  --boxSecond: var(--purple);
  --boxHigh: var(--yellow);
  --border: 1vmin solid var(--black);
  --borderRad: 2px;
}

* {
  box-sizing: border-box;
}

body {
  background-color: var(--white);
  padding: 1vmax;
  font-family: sans-serif, system-ui;
  font-size: 60%;
  color: var(--black);
}

h2 {
  font-size: 0.8.em;
}

/* loading ~~~~~~~~~~~~~~~~~~~~~ */
.loading {
  background: var(--white);
  position: absolute;
  left: 0;
  right: 0;
  top: 0;
  bottom: 0;
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

/* sequencer ~~~~~~~~~~~~~~~~~~~~~~~~~ */
#sequencer {
  width: 84vw;
  max-width: 900px;
  min-width: 600px;
  margin: 0 auto;
  background-color: var(--boxMain);
  border: var(--border);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~ top section */
.controls-main {
  padding: 1vw;
  background-color: var(--boxSecond);
  border-bottom: var(--border);
  display: grid;
  grid-template-rows: auto;
  grid-template-columns: repeat(5, auto);
  align-items: center;
}

.controls-main label {
  justify-self: end;
  padding-right: 10px;
}

.controls-main span {
  padding-left: 10px;
}

/* play button */
#playBtn:checked {
  align-self: stretch;
  border: var(--border);
  border-radius: var(--borderRad);
  background-color: var(--boxSecond);
  cursor: pointer;
}

#playBtn {
  appearance: none;
  width: 9vw;
  height: 1vw;
  min-width: 36px;
  min-height: 36px;
  max-width: 112px;
  max-height: 40x;
  margin: 0;
  padding: 0;
  border: var(--border);
  border-radius: var(--borderRad);
  background: var(--pink)
    url('data:image/svg+xml;charset=utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512"><path d="M424.4 214.7L72.4 6.6C43.8-10.3 0 6.1 0 47.9V464c0 37.5 40.7 60.1 72.4 41.3l352-208c31.4-18.5 31.5-64.1 0-82.6z" fill="black" /></svg>')
    no-repeat center center;
  background-size: 60% 60%;
  cursor: pointer;
}

#playBtn ~ label {
  display: none;
}

#playBtn:hover,
#playBtn:checked:hover {
  background-color: var(--yellow);
}

#playBtn:checked {
  background: var(--green)
    url('data:image/svg+xml;charset=utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512"><path d="M400 32H48C21.5 32 0 53.5 0 80v352c0 26.5 21.5 48 48 48h352c26.5 0 48-21.5 48-48V80c0-26.5-21.5-48-48-48z" fill="black" /></svg>')
    no-repeat center center;
  background-size: 60% 60%;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~ main body */
[class^="track"] {
  display: grid;
  grid-template-rows: auto;
  grid-template-columns: 15% 35% 50%;
  align-items: center;
  padding: 1vmin;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~ sliders */
.controls {
  display: grid;
  grid-template-rows: repeat(2, auto);
  grid-template-columns: 1fr 4fr;
  align-items: center;
}

.controls label {
  justify-self: end;
  padding-right: 10px;
}

.controls input {
  margin-right: 20px;
}

.controls input:nth-of-type(2),
.controls label:nth-of-type(2) {
  margin-top: 10px;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~ pads */
.pads {
  display: flex;
  justify-content: space-between;
}

.pads input {
  appearance: none;
  width: 9vw;
  height: 1vw;
  min-width: 56px;
  min-height: 56px;
  max-width: 96px;
  max-height: 40px;
  margin: 0;
  padding: 0;
  background-color: var(--white);
  border: var(--border);
}

.pads input:checked {
  background-color: var(--boxHigh);
}

.pads label {
  display: none;
}

/* range input styling ~~~~~~~~~~~~~~~~~~~ */

input[type="range"] {
  -webkit-appearance: none;
  background: transparent;
}

input[type="range"]::-ms-track {
  width: 100%;
  cursor: pointer;
  background: transparent;
  border-color: transparent;
  color: transparent;
}

input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  margin-top: -1vh;
  height: 1vh;
  width: 2vw;
  border: 0.5vmin solid var(--black);
  border-radius: var(--borderRad);
  background-color: var(--boxSecond);
  cursor: pointer;
}

input[type="range"]::-moz-range-thumb {
  height: 1vh;
  width: 2vw;
  border: 0.5vmin solid var(--black);
  border-radius: var(--borderRad);
  background-color: var(--boxSecond);
  cursor: pointer;
}

input[type="range"]::-ms-thumb {
  height: 1vh;
  width: 1vw;
  border: 0.5vmin solid var(--black);
  border-radius: var(--borderRad);
  background-color: var(--boxSecond);
  cursor: pointer;
}

input[type="range"]::-webkit-slider-runnable-track {
  height: 1vh;
  cursor: pointer;
  background-color: var(--black);
  border-radius: var(--borderRad);
}

input[type="range"]::-moz-range-track {
  height: 1vh;
  cursor: pointer;
  background-color: var(--black);
  border-radius: var(--borderRad);
}

input[type="range"]::-ms-track {
  height: 1vh;
  cursor: pointer;
  background-color: var(--black);
  border-radius: var(--borderRad);
}

input[type="range"]:focus {
  outline: none;
}

input[type="range"]:focus::-webkit-slider-thumb {
  background-color: var(--boxHigh);
}

input[type="range"]:focus::-moz-range-thumb {
  background-color: var(--boxHigh);
}

input[type="range"]:focus::-ms-thumb {
  background-color: var(--boxHigh);
}

</style>
<body>

    <div id="sequencer">
      <section class="controls-main">
        <h1>ModemDN</h1>
        <label for="bpm">BPM</label>
        <input
          name="bpm"
          id="bpm"
          type="range"
          min="60"
          max="180"
          value="120"
          step="1" />
        <span id="bpmval">120</span>
        <input type="checkbox" id="playBtn" />
        <label for="playBtn">Play</label>
      </section>

      <div id="tracks">
        <!-- track one: bleep -->
        <section class="track-one">
          <h2>Sweep</h2>
          <section class="controls">
            <label for="attack">Att</label>
            <input
              name="attack"
              id="attack"
              type="range"
              min="0"
              max="1"
              value="0.2"
              step="0.1" />
            <label for="release">Rel</label>
            <input
              name="release"
              id="release"
              type="range"
              min="0"
              max="1"
              value="0.5"
              step="0.1" />
          </section>

          <section class="pads">
            <input type="checkbox" id="v1n1" />
            <label for="v1n1">Voice 1, Note 1</label>

            <input type="checkbox" id="v1n2" />
            <label for="v1n2">Voice 1, Note 2</label>

            <input type="checkbox" id="v1n3" />
            <label for="v1n3">Voice 1, Note 3</label>

            <input type="checkbox" id="v1n4" />
            <label for="v1n4">Voice 1, Note 4</label>
          </section>
        </section>

        <!-- track two: pad/sweep -->
        <section class="track-two">
          <h2>Pulse</h2>
          <section class="controls">
            <label for="hz">Hz</label>
            <input
              name="hz"
              id="hz"
              type="range"
              min="660"
              max="1320"
              value="880"
              step="1" />
            <label for="lfo">LFO</label>
            <input
              name="lfo"
              id="lfo"
              type="range"
              min="20"
              max="40"
              value="30"
              step="1" />
          </section>
          <!--

          -->
          <section class="pads">
            <input type="checkbox" id="v2n1" />
            <label for="v2n1">Voice 2, Note 1</label>

            <input type="checkbox" id="v2n2" />
            <label for="v2n2">Voice 2, Note 2</label>

            <input type="checkbox" id="v2n3" />
            <label for="v2n3">Voice 2, Note 3</label>

            <input type="checkbox" id="v2n4" />
            <label for="v2n4">Voice 2, Note 4</label>
          </section>
        </section>

        <!-- track three: noise -->
        <section class="track-three">
          <h2>Noise</h2>
          <section class="controls">
            <label for="duration">Dur</label>
            <input
              name="duration"
              id="duration"
              type="range"
              min="0.25"
              max="1"
              value="1"
              step="0.25" />
            <label for="band">Band</label>
            <input
              name="band"
              id="band"
              type="range"
              min="400"
              max="1200"
              value="1000"
              step="5" />
          </section>

          <section class="pads">
            <input type="checkbox" id="v3n1" />
            <label for="v3n1">Voice 3, Note 1</label>

            <input type="checkbox" id="v3n2" />
            <label for="v3n2">Voice 3, Note 2</label>

            <input type="checkbox" id="v3n3" />
            <label for="v3n3">Voice 3, Note 3</label>

            <input type="checkbox" id="v3n4" />
            <label for="v3n4">Voice 3, Note 4</label>
          </section>
        </section>

        <!-- track four: drill -->
        <section class="track-four">
          <h2>DTMF</h2>
          <section class="controls">
            <label for="rate">Rate</label>
            <input
              name="rate"
              id="rate"
              type="range"
              min="0.1"
              max="2"
              value="1"
              step="0.1" />
          </section>
          <!--

          -->
          <section class="pads">
            <input type="checkbox" id="v4n1" />
            <label for="v4n1">Voice 4, Note 1</label>

            <input type="checkbox" id="v4n2" />
            <label for="v4n2">Voice 4, Note 2</label>

            <input type="checkbox" id="v4n3" />
            <label for="v4n3">Voice 4, Note 3</label>

            <input type="checkbox" id="v4n4" />
            <label for="v4n4">Voice 4, Note 4</label>
          </section>
        </section>
      </div>
    </div>
    <!-- sequencer -->

<script>

const wavetableSource = {
  real: [
    0.0, -0.000001, -0.085114, 0.113655, -0.053293, 0.034018, -0.024299,
    0.01707, -0.015971, 0.01553, -0.012639, 0.011335, -0.011541, 0.01043,
    -0.009167, 0.008078, -0.007356, 0.007138, -0.006327, 0.005447, -0.00315,
    0.002063, -0.001783, 0.00164, -0.001605, 0.001391, -0.001283, 0.001259,
    -0.001237, 0.001178, -0.001159, 0.00114, -0.001193, 0.001249, -0.001231,
    0.00133, -0.001312, 0.001419, -0.001489, 0.00147, -0.001641, 0.001723,
    -0.002245, 0.002587, -0.003811, 0.004531, -0.005556, 0.007028, -0.009168,
    0.010259, -0.011842, 0.013671, -0.013539, 0.01383, -0.012496, 0.012382,
    -0.010525, 0.008948, -0.007155, 0.00476, -0.004305, 0.003046, -0.003021,
    0.002571, -0.002399, 0.002042, -0.002026, 0.002011, -0.001766, 0.0017,
    -0.001688, 0.001676, -0.001664, 0.001653, -0.001641, 0.001681, -0.00167,
    0.002057, -0.002044, 0.002031, -0.002213, 0.0022, -0.002186, 0.002311,
    -0.002297, 0.002283, -0.002647, 0.002631, -0.002617, 0.002602, -0.002751,
    0.002736, -0.002721, 0.002878, -0.002863, 0.002936, -0.002664, 0.00257,
    -0.002804, 0.002877, -0.002862, 0.002848, -0.003204, 0.003189, -0.003174,
    0.003158, -0.003144, 0.003129, -0.003114, 0.0031, -0.003086, 0.003072,
    -0.003058, 0.00314, -0.003126, 0.003112, -0.003099, 0.003086, -0.003073,
    0.00306, -0.003047, 0.003034, -0.002756, 0.002745, -0.002734, 0.002723,
    -0.002712, 0.002701, -0.002691, 0.00268, -0.00267, 0.00266, -0.00265,
    0.00264, -0.00263, 0.00262, -0.00261, 0.002601, -0.002591, 0.002582,
    -0.002573, 0.002486, -0.002477, 0.002469, -0.00246, 0.002452, -0.002443,
    0.002435, -0.002081, 0.002074, -0.002067, 0.002061, -0.002054, 0.002047,
    -0.001861, 0.001855, -0.001849, 0.001843, -0.001837, 0.001831, -0.001826,
    0.001711, -0.001706, 0.001701, -0.001696, 0.001691, -0.001685, 0.00168,
    -0.001576, 0.001571, -0.001566, 0.001562, -0.001557, 0.001553, -0.001456,
    0.001452, -0.001447, 0.001443, -0.001439, 0.001435, -0.001388, 0.001384,
    -0.00138, 0.001376, -0.001041, 0.001038, -0.001036, 0.001033, -0.00103,
    0.001027, -0.001025, 0.001022, -0.000874, 0.000872, -0.00087, 0.000867,
    -0.000865, 0.000837, -0.000835, 0.000833, -0.000757, 0.000755, -0.000754,
    0.000752, -0.000663, 0.000662, -0.00066, 0.000658, -0.001141, 0.001138,
    -0.001136, 0.001133, -0.00113, 0.001128, -0.000755, 0.000753, -0.000751,
    0.000773, -0.000771, 0.000769, -0.000767, 0.000766, -0.000764, 0.000762,
    -0.00076, 0.000759, -0.000757, 0.000755, -0.000753, 0.000752, -0.000798,
    0.000796, -0.000794, 0.000792, -0.000791, 0.000789, -0.000787, 0.000786,
    -0.000784, 0.000782, -0.00078, 0.000779, -0.000777, 0.000775, -0.000774,
    0.000772, -0.000771, 0.000769, -0.000767, 0.000766, -0.000764, 0.000836,
    -0.000835, 0.000833, -0.000831, 0.000829, -0.000854, 0.000852, -0.00085,
    0.000848, -0.000847, 0.000845, -0.000843, 0.000842, -0.00084, 0.000838,
    -0.000837, 0.000835, -0.000833, 0.000832, -0.00083, 0.000829, -0.000827,
    0.000825, -0.000824, 0.000822, -0.000821, 0.000819, -0.000818, 0.000816,
    -0.000815, 0.000813, -0.000812, 0.00081, -0.000809, 0.000783, -0.000781,
    0.00078, -0.000778, 0.000777, -0.000775, 0.000751, -0.000749, 0.000748,
    -0.000747, 0.000745, -0.000744, 0.000743, -0.000741, 0.00074, -0.000739,
    0.000737, -0.000736, 0.000735, -0.000733, 0.000732, -0.000731, 0.000729,
    -0.000728, 0.000727, -0.000726, 0.000724, -0.000723, 0.000722, -0.000721,
    0.000719, -0.000718, 0.000717, -0.000716, 0.000714, -0.000713, 0.000712,
    -0.000711, 0.00071, -0.000708, 0.000707, -0.000706, 0.000705, -0.000704,
    0.000702, -0.000701, 0.0007, -0.000699, 0.000698, -0.000697, 0.000696,
    -0.000694, 0.000693, -0.000692, 0.000691, -0.00069, 0.000689, -0.000688,
    0.000686, -0.000685, 0.000684, -0.000704, 0.000703, -0.000702, 0.000701,
    -0.0007, 0.000699, -0.000698, 0.000696, -0.000695, 0.000694, -0.000693,
    0.000692, -0.000691, 0.00069, -0.000689, 0.000688, -0.000686, 0.000685,
    -0.000684, 0.000683, -0.000682, 0.000681, -0.00068, 0.000679, -0.000678,
    0.000677, -0.000676, 0.000675, -0.000674, 0.000672, -0.000671, 0.00067,
    -0.000669, 0.000668, -0.000667, 0.000666, -0.000665, 0.000664, -0.000663,
    0.000662, -0.000661, 0.00066, -0.000659, 0.000658, -0.000657, 0.000656,
    -0.000655, 0.000654, -0.000653, 0.000652, -0.000651, 0.00065, -0.000649,
    0.000648, -0.000647, 0.000646, -0.000645, 0.000644, -0.000643, 0.000642,
    -0.000641, 0.00064, -0.000639, 0.000638, -0.000637, 0.000636, -0.000635,
    0.000634, -0.000614, 0.000613, -0.000612, 0.000611, -0.00061, 0.000609,
    -0.000608, 0.000607, -0.000607, 0.000606, -0.000605, 0.000604, -0.000603,
    0.000602, -0.000601, 0.0006, -0.000599, 0.000598, -0.000597, 0.000596,
    -0.000596, 0.000595, -0.000594, 0.000593, -0.000592, 0.000591, -0.00059,
    0.000589, -0.000588, 0.000587, -0.000587, 0.000586, -0.000585, 0.000584,
    -0.000583, 0.000582, -0.000581, 0.00058, -0.000579, 0.000579, -0.000578,
    0.000577, -0.000576, 0.000575, -0.000574, 0.000573, -0.000572, 0.000571,
    -0.000571, 0.00057, -0.000569, 0.000568, -0.000567, 0.000566, -0.000565,
    0.000564, -0.000564, 0.000563, -0.000562, 0.000561, -0.00056, 0.000559,
    -0.000558, 0.000558, -0.000557, 0.000556, -0.000555, 0.000554, -0.000553,
    0.000552, -0.000473, 0.000472, -0.000472, 0.000471, -0.00047, 0.000469,
    -0.000469, 0.000468, -0.000467, 0.000466, -0.000466, 0.000465, -0.000464,
    0.000463, -0.000463, 0.000462, -0.000461, 0.000461, -0.00046, 0.000459,
    -0.000458, 0.000458, -0.000457, 0.000456, -0.000455, 0.000455, -0.000454,
    0.000453, -0.000452, 0.000452, -0.000451, 0.00045, -0.00045, 0.000449,
    -0.000448, 0.000447, -0.000447, 0.000446, -0.000445, 0.000445, -0.000444,
    0.000443, -0.000442, 0.000442, -0.000441, 0.00044, -0.000439, 0.000439,
    -0.000438, 0.000437, -0.000437, 0.000436, -0.000435, 0.000434, -0.000434,
    0.000433, -0.000432, 0.000431, -0.000431, 0.00043, -0.000429, 0.000429,
    -0.000428, 0.000427, -0.000426, 0.000426, -0.000425, 0.000424, -0.000423,
    0.000423, -0.000422, 0.000421, -0.000421, 0.00042, -0.000419, 0.000418,
    -0.000418, 0.000417, -0.000416, 0.000415, -0.000415, 0.000414, -0.000413,
    0.000413, -0.000412, 0.000411, -0.00041, 0.00041, -0.000409, 0.000408,
    -0.000407, 0.000407, -0.000406, 0.000405, -0.000405, 0.000404, -0.000403,
    0.000402, -0.000402, 0.000401, -0.0004, 0.000399, -0.000399, 0.000398,
    -0.000397, 0.000396, -0.000396, 0.000349, -0.000349, 0.000348, -0.000347,
    0.000347, -0.000346, 0.000345, -0.000345, 0.000344, -0.000343, 0.000343,
    -0.000342, 0.000341, -0.000341, 0.00034, -0.00034, 0.000339, -0.000338,
    0.000338, -0.000337, 0.000336, -0.000336, 0.000335, -0.000334, 0.000334,
    -0.000333, 0.000332, -0.000332, 0.000331, -0.00033, 0.00033, -0.000329,
    0.000328, -0.000328, 0.000327, -0.000326, 0.000326, -0.000325, 0.000324,
    -0.000324, 0.000323, -0.000322, 0.000322, -0.000321, 0.00032, -0.00032,
    0.000319, -0.000318, 0.000318, -0.000317, 0.000316, -0.000316, 0.000315,
    -0.000314, 0.000314, -0.000313, 0.000312, -0.000311, 0.000311, -0.00031,
    0.000309, -0.000309, 0.000308, -0.000307, 0.000307, -0.000306, 0.000305,
    -0.000305, 0.000304, -0.000303, 0.000303, -0.000302, 0.000301, -0.000301,
    0.0003, -0.000299, 0.000298, -0.000298, 0.000297, -0.000296, 0.000296,
    -0.000295, 0.000294, -0.000294, 0.000293, -0.000292, 0.000291, -0.000291,
    0.00029, -0.000289, 0.000271, -0.000271, 0.00027, -0.00027, 0.000269,
    -0.000268, 0.000268, -0.000267, 0.000266, -0.000266, 0.000265, -0.000264,
    0.000264, -0.000263, 0.000262, -0.000262, 0.000261, -0.00026, 0.000259,
    -0.000259, 0.000258, -0.000257, 0.000257, -0.000256, 0.000255, -0.000255,
    0.000254, -0.000253, 0.000253, -0.000252, 0.000251, -0.000251, 0.00025,
    -0.000249, 0.000249, -0.000248, 0.000247, -0.000247, 0.000246, -0.000245,
    0.000245, -0.000244, 0.000243, -0.000242, 0.000242, -0.000241, 0.00024,
    -0.00024, 0.000239, -0.000238, 0.000238, -0.000237, 0.000236, -0.000235,
    0.000235, -0.000234, 0.000233, -0.000233, 0.000232, -0.000231, 0.000231,
    -0.00023, 0.000229, -0.000228, 0.000228, -0.000227, 0.000226, -0.000226,
    0.000225, -0.000224, 0.000223, -0.000223, 0.000222, -0.000221, 0.000221,
    -0.00022, 0.000219, -0.000218, 0.000218, -0.000217, 0.000216, -0.000216,
    0.000215, -0.000214, 0.000213, -0.000213, 0.000212, -0.000211, 0.00021,
    -0.00021, 0.000209, -0.000208, 0.000208, -0.000207, 0.000206, -0.000205,
    0.000205, -0.000204, 0.000203, -0.000202, 0.000178, -0.000178, 0.000177,
    -0.000176, 0.000176, -0.000175, 0.000174, -0.000174, 0.000173, -0.000172,
    0.000172, -0.000171, 0.00017, -0.00017, 0.000169, -0.000168, 0.000168,
    -0.000167, 0.000166, -0.000166, 0.000165, -0.000164, 0.000164, -0.000163,
    0.000162, -0.000162, 0.000161, -0.00016, 0.00016, -0.000159, 0.000158,
    -0.000158, 0.000157, -0.000156, 0.000156, -0.000155, 0.000154, -0.000154,
    0.000153, -0.000152, 0.000152, -0.000151, 0.00015, -0.000149, 0.000149,
    -0.000148, 0.000147, -0.000147, 0.000146, -0.000145, 0.000145, -0.000144,
    0.000143, -0.000143, 0.000142, -0.000141, 0.000141, -0.00014, 0.000139,
    -0.000138, 0.000138, -0.000137, 0.000136, -0.000136, 0.000135, -0.000134,
    0.000134, -0.000133, 0.000132, -0.000131, 0.000131, -0.00013, 0.000129,
    -0.000129, 0.000128, -0.000127, 0.000126, -0.000126, 0.000125, -0.000124,
    0.000124, -0.000123, 0.000122, -0.000121, 0.000121, -0.00012, 0.000119,
    -0.000118, 0.000118, -0.000117, 0.000116, -0.000116, 0.000115, -0.000114,
    0.000113, -0.000113, 0.000112, -0.000111, 0.000111, -0.00011, 0.000109,
    -0.000108, 0.000108, -0.000107, 0.000106, -0.000105, 0.000105, -0.000104,
    0.000103, -0.000103, 0.000102, -0.000101, 0.0001, -0.0001, 0.000099,
    -0.000098, 0.000097, -0.000097, 0.000096, -0.000095, 0.000094, -0.000094,
    0.000093, -0.000092, 0.000091, -0.000091, 0.00009, -0.000089, 0.000088,
    -0.000088, 0.000087, -0.000086, 0.000085, -0.000085, 0.000084, -0.000083,
    0.000083, -0.000082, 0.000081, -0.00008, 0.000079, -0.000079, 0.000078,
    -0.000077, 0.000076, -0.000076, 0.000075, -0.000074, 0.000073, -0.000073,
    0.000072, -0.000071, 0.00007, -0.00007, 0.000069, -0.000068, 0.000067,
    -0.000067, 0.000066, -0.000065, 0.000064, -0.000064, 0.000063, -0.000062,
    0.000061, -0.00006, 0.00006, -0.000059, 0.000058, -0.000057, 0.000057,
    -0.000056, 0.000055, -0.000054, 0.000052, -0.000051, 0.000051, -0.00005,
    0.000049, -0.000048, 0.000048, -0.000047, 0.000046, -0.000045, 0.000045,
    -0.000044, 0.000043, -0.000042, 0.000042, -0.000041, 0.00004, -0.000039,
    0.000039, -0.000038, 0.000037, -0.000036, 0.000036, -0.000035, 0.000034,
    -0.000033, 0.000033, -0.000032, 0.000031, -0.00003, 0.000029, -0.000029,
    0.000028, -0.000027, 0.000026, -0.000026, 0.000025, -0.000024, 0.000023,
    -0.000023, 0.000022, -0.000021, 0.00002, -0.00002, 0.000019, -0.000018,
    0.000017, -0.000017, 0.000016, -0.000015, 0.000014, -0.000014, 0.000013,
    -0.000012, 0.000011, -0.000011, 0.00001, -0.000009, 0.000008, -0.000008,
    0.000007, -0.000006, 0.000005, -0.000005, 0.000004, -0.000003, 0.000002,
    -0.000002, 0.000001, -0.0, -0.000001, 0.000002, -0.000002, 0.000003,
    -0.000004, 0.000005, -0.000005, 0.000006, -0.000007, 0.000008, -0.000008,
    0.000009, -0.00001, 0.000011, -0.000011, 0.000012, -0.000013, 0.000014,
    -0.000014, 0.000015, -0.000016, 0.000017, -0.000017, 0.000018, -0.000019,
    0.00002, -0.00002, 0.000021, -0.000022, 0.000023, -0.000024, 0.000024,
    -0.000025, 0.000026, -0.000027, 0.000027, -0.000028, 0.000029, -0.00003,
    0.00003, -0.000031, 0.000032, -0.000033, 0.000033, -0.000034, 0.000035,
    -0.000036, 0.000036, -0.000037, 0.000038, -0.000039, 0.000039, -0.00004,
    0.000041, -0.000041, 0.000042, -0.000043, 0.000044, -0.000044, 0.000045,
    -0.000046, 0.000047, -0.000047, 0.000048, -0.000049, 0.00005, -0.00005,
    0.000051, -0.000052, 0.000053, -0.000053, 0.000054, -0.000055, 0.000056,
    -0.000056, 0.000057, -0.000058, 0.000059, -0.000059, 0.00006, -0.000061,
    0.000062, -0.000062, 0.000063, -0.000064, 0.000065, -0.000065, 0.000066,
    -0.000067, 0.000067, -0.000068, 0.000069, -0.00007, 0.00007, -0.000071,
    0.000072, -0.000073, 0.000073, -0.000074, 0.000075, -0.000075, 0.000076,
    -0.000077, 0.000078, -0.000078, 0.000079, -0.00008, 0.00008, -0.000081,
    0.000082, -0.000083, 0.000083, -0.000084, 0.000085, -0.000085, 0.000086,
    -0.000087, 0.000087, -0.000088, 0.000089, -0.00009, 0.00009, -0.000091,
    0.000092, -0.000092, 0.000093, -0.000094, 0.000095, -0.000095, 0.000096,
    -0.000097, 0.000097, -0.000098, 0.000099, -0.000099, 0.0001, -0.000101,
    0.000101, -0.000102, 0.000103, -0.000104, 0.000104, -0.000105, 0.000106,
    -0.000106, 0.000107, -0.000108, 0.000108, -0.000109, 0.000109, -0.00011,
    0.000111, -0.000112, 0.000112, -0.000113, 0.000114, -0.000114, 0.000115,
    -0.000116, 0.000116, -0.000117, 0.000118, -0.000118, 0.000119, -0.000119,
    0.00012, -0.000121, 0.000121, -0.000122, 0.000123, -0.000123, 0.000124,
    -0.000125, 0.000125, -0.000126, 0.000126, -0.000127, 0.000128, -0.000128,
    0.000129, -0.00013, 0.00013, -0.000131, 0.000131, -0.000132, 0.000133,
    -0.000133, 0.000134, -0.000135, 0.000135, -0.000136, 0.000136, -0.000137,
    0.000138, -0.000138, 0.000139, -0.000139, 0.00014, -0.00014, 0.000141,
    -0.000142, 0.000142, -0.000143, 0.000144, -0.000144, 0.000145, -0.000145,
    0.000146, -0.000146, 0.000147, -0.000148, 0.000148, -0.000149, 0.000149,
    -0.00015, 0.00015, -0.000151, 0.000152, -0.000152, 0.000153, -0.000153,
    0.000154, -0.000154, 0.000155, -0.000155, 0.000156, -0.000156, 0.000157,
    -0.000157, 0.000158, -0.000159, 0.000159, -0.00016, 0.00016, -0.000161,
    0.000161, -0.000162, 0.000162, -0.000163, 0.000163, -0.000164, 0.000164,
    -0.000165, 0.000165, -0.000166, 0.000166, -0.000167, 0.000178, -0.000178,
    0.000179, -0.000179, 0.00018, -0.00018, 0.000181, -0.000181, 0.000182,
    -0.000182, 0.000183, -0.000183, 0.000184, -0.000184, 0.000185, -0.000185,
    0.000186, -0.000186, 0.000187, -0.000187, 0.000188, -0.000188, 0.000189,
    -0.000189, 0.00019, -0.00019, 0.000191, -0.000191, 0.000191, -0.000192,
    0.000192, -0.000193, 0.000193, -0.000194, 0.000194, -0.000194, 0.000195,
    -0.000195, 0.000196, -0.000196, 0.000197, -0.000197, 0.000197, -0.000198,
    0.000198, -0.000199, 0.000199, -0.000199, 0.0002, -0.0002, 0.000201,
    -0.000201, 0.000201, -0.000202, 0.000202, -0.000202, 0.000203, -0.000203,
    0.000204, -0.000204, 0.000204, -0.000205, 0.000205, -0.000205, 0.000206,
    -0.000206, 0.000206, -0.000207, 0.000207, -0.000207, 0.000208, -0.000208,
    0.000208, -0.000209, 0.000209, -0.000209, 0.000209, -0.00021, 0.00021,
    -0.00021, 0.000211, -0.000211, 0.000211, -0.000211, 0.000212, -0.000212,
    0.000212, -0.000213, 0.000213, -0.000213, 0.000213, -0.000214, 0.000214,
    -0.000214, 0.000214, -0.000215, 0.000215, -0.000215, 0.000215, -0.000215,
    0.000216, -0.000216, 0.000216, -0.000216, 0.000217, -0.000217, 0.000217,
    -0.000217, 0.000217, -0.000217, 0.000218, -0.000218, 0.000218, -0.000218,
    0.000218, -0.000219, 0.000219, -0.000219, 0.000219, -0.000219, 0.000219,
    -0.000219, 0.00022, -0.00022, 0.00022, -0.00022, 0.00022, -0.00022, 0.00022,
    -0.00022, 0.000221, -0.000221, 0.000221, -0.000221, 0.000221, -0.000221,
    0.000221, -0.000221, 0.000221, -0.000221, 0.000221, -0.000221, 0.000222,
    -0.000222, 0.000222, -0.000222, 0.000222, -0.000222, 0.000222, -0.000222,
    0.000222, -0.000222, 0.000222, -0.000222, 0.000222, -0.000222, 0.000222,
    -0.000222, 0.000222, -0.000222, 0.000222, -0.000222, 0.000222, -0.000222,
    0.000222, -0.000222, 0.000222, -0.000222, 0.000222, -0.000222, 0.000222,
    -0.000222, 0.000222, -0.000222, 0.000221, -0.000221, 0.000221, -0.000221,
    0.000221, -0.000221, 0.000221, -0.000221, 0.000221, -0.000221, 0.000221,
    -0.00022, 0.00022, -0.00022, 0.00022, -0.00022, 0.00022, -0.00022, 0.00022,
    -0.000219, 0.000219, -0.000219, 0.000219, -0.000219, 0.000219, -0.000218,
    0.000218, -0.000218, 0.000218, -0.000218, 0.000218, -0.000217, 0.000217,
    -0.000217, 0.000217, -0.000217, 0.000216, -0.000216, 0.000216, -0.000216,
    0.000215, -0.000215, 0.000215, -0.000215, 0.000215, -0.000214, 0.000214,
    -0.000214, 0.000213, -0.000213, 0.000213, -0.000213, 0.000212, -0.000212,
    0.000212, -0.000211, 0.000211, -0.000211, 0.000211, -0.00021, 0.00021,
    -0.00021, 0.000209, -0.000209, 0.000209, -0.000208, 0.000208, -0.000208,
    0.000207, -0.000207, 0.000207, -0.000206, 0.000206, -0.000205, 0.000205,
    -0.000205, 0.000204, -0.000204, 0.000204, -0.000203, 0.000203, -0.000202,
    0.000202, -0.000202, 0.000201, -0.000201, 0.0002, -0.0002, 0.000199,
    -0.000199, 0.000199, -0.000198, 0.000198, -0.000197, 0.000197, -0.000196,
    0.000196, -0.000195, 0.000195, -0.000194, 0.000194, -0.000193, 0.000193,
    -0.000192, 0.000192, -0.000191, 0.000191, -0.00019, 0.00019, -0.000189,
    0.000189, -0.000188, 0.000188, -0.000187, 0.000187, -0.000186, 0.000186,
    -0.000185, 0.000185, -0.000184, 0.000183, -0.000183, 0.000182, -0.000182,
    0.000181, -0.000181, 0.00018, -0.000179, 0.000179, -0.000178, 0.000178,
    -0.000177, 0.000176, -0.000176, 0.000175, -0.000175, 0.000174, -0.000173,
    0.000173, -0.000172, 0.000171, -0.000171, 0.00017, -0.000169, 0.000169,
    -0.000168, 0.000167, -0.000167, 0.000166, -0.000165, 0.000165, -0.000164,
    0.000163, -0.000163, 0.000162, -0.000161, 0.000161, -0.00016, 0.000159,
    -0.000158, 0.000158, -0.000157, 0.000156, -0.000156, 0.000155, -0.000154,
    0.000153, -0.000153, 0.000152, -0.000151, 0.00015, -0.00015, 0.000149,
    -0.000148, 0.000147, -0.000147, 0.000146, -0.000145, 0.000144, -0.000143,
    0.000143, -0.000142, 0.000141, -0.00014, 0.000139, -0.000139, 0.000138,
    -0.000137, 0.000136, -0.000135, 0.000135, -0.000134, 0.000133, -0.000132,
    0.000131, -0.00013, 0.00013, -0.000129, 0.000128, -0.000127, 0.000126,
    -0.000125, 0.000125, -0.000124, 0.000123, -0.000122, 0.000121, -0.00012,
    0.000119, -0.000118, 0.000118, -0.000117, 0.000116, -0.000115, 0.000114,
    -0.000113, 0.000112, -0.000111, 0.00011, -0.00011, 0.000109, -0.000108,
    0.000107, -0.000106, 0.000105, -0.000104, 0.000103, -0.000102, 0.000101,
    -0.0001, 0.000099, -0.000099, 0.000098, -0.000097, 0.000096, -0.000095,
    0.000094, -0.000093, 0.000092, -0.000091, 0.00009, -0.000089, 0.000088,
    -0.000087, 0.000086, -0.000085, 0.000084, -0.000083, 0.000082, -0.000081,
    0.00008, -0.000079, 0.000078, -0.000077, 0.000076, -0.000075, 0.000074,
    -0.000073, 0.000072, -0.000071, 0.00007, -0.000069, 0.000068, -0.000067,
    0.000066, -0.000065, 0.000064, -0.000063, 0.000062, -0.000061, 0.00006,
    -0.000059, 0.000058, -0.000057, 0.000056, -0.000055, 0.000054, -0.000053,
    0.000052, -0.000051, 0.00005, -0.000049, 0.000048, -0.000047, 0.000046,
    -0.000045, 0.000044, -0.000043, 0.000042, -0.000041, 0.00004, -0.000039,
    0.000038, -0.000037, 0.000036, -0.000035, 0.000033, -0.000032, 0.000031,
    -0.00003, 0.000029, -0.000028, 0.000027, -0.000026, 0.000025, -0.000024,
    0.000023, -0.000022, 0.000021, -0.00002, 0.000019, -0.000018, 0.000017,
    -0.000016, 0.000014, -0.000013, 0.000012, -0.000011, 0.00001, -0.000009,
    0.000008, -0.000007, 0.000006, -0.000005, 0.000004, -0.000003, 0.000002,
    -0.000001, -0.0, 0.000001, -0.000003, 0.000004, -0.000005, 0.000006,
    -0.000007, 0.000008, -0.000009, 0.00001, -0.000011, 0.000012, -0.000013,
    0.000014, -0.000015, 0.000016, -0.000017, 0.000018, -0.00002, 0.000021,
    -0.000022, 0.000023, -0.000024, 0.000025, -0.000026, 0.000027, -0.000028,
    0.000029, -0.00003, 0.000031, -0.000032, 0.000033, -0.000034, 0.000035,
    -0.000036, 0.000037, -0.000038, 0.000039, -0.000041, 0.000041, -0.000043,
    0.000044, -0.000045, 0.000046, -0.000047, 0.000048, -0.000049, 0.00005,
    -0.000051, 0.000052, -0.000053, 0.000054, -0.000055, 0.000056, -0.000057,
    0.000058, -0.000059, 0.00006, -0.000061, 0.000062, -0.000063, 0.000064,
    -0.000065, 0.000066, -0.000067, 0.000068, -0.000069, 0.00007, -0.000071,
    0.000072, -0.000073, 0.000074, -0.000075, 0.000076, -0.000077, 0.000078,
    -0.000079, 0.00008, -0.000081, 0.000082, -0.000083, 0.000084, -0.000085,
    0.000086, -0.000087, 0.000088, -0.000089, 0.00009, -0.00009, 0.000091,
    -0.000092, 0.000093, -0.000094, 0.000095, -0.000096, 0.000097, -0.000098,
    0.000099, -0.0001, 0.000101, -0.000101, 0.000102, -0.000103, 0.000104,
    -0.000105, 0.000106, -0.000107, 0.000108, -0.000109, 0.000109, -0.00011,
    0.000111, -0.000112, 0.000113, -0.000114, 0.000115, -0.000116, 0.000116,
    -0.000117, 0.000118, -0.000119, 0.00012, -0.000121, 0.000121, -0.000122,
    0.000123, -0.000124, 0.000125, -0.000125, 0.000126, -0.000127, 0.000128,
    -0.000129, 0.000129, -0.00013, 0.000131, -0.000132, 0.000133, -0.000133,
    0.000134, -0.000135, 0.000136, -0.000149, 0.00015, -0.000151, 0.000152,
    -0.000153, 0.000153, -0.000154, 0.000155, -0.000156, 0.000157, -0.000157,
    0.000158, -0.000159, 0.00016, -0.00016, 0.000161, -0.000162, 0.000163,
    -0.000163, 0.000164, -0.000165, 0.000165, -0.000166, 0.000167, -0.000168,
    0.000168, -0.000169, 0.00017, -0.00017, 0.000171, -0.000172, 0.000172,
    -0.000173, 0.000174, -0.000174, 0.000175, -0.000175, 0.000176, -0.000177,
    0.000177, -0.000178, 0.000178, -0.000179, 0.00018, -0.00018, 0.000181,
    -0.000181, 0.000182, -0.000182, 0.000183, -0.000184, 0.000184, -0.000185,
    0.000185, -0.000186, 0.000186, -0.000187, 0.000187, -0.000188, 0.000188,
    -0.000189, 0.000189, -0.00019, 0.00019, -0.00019, 0.000191, -0.000191,
    0.000192, -0.000192, 0.000193, -0.000193, 0.000193, -0.000194, 0.000194,
    -0.000195, 0.000195, -0.000195, 0.000196, -0.000196, 0.000196, -0.000197,
    0.000197, -0.000197, 0.000198, -0.000198, 0.000198, -0.000199, 0.000199,
    -0.000199, 0.000199, -0.0002, 0.0002, -0.0002, 0.0002, -0.000201, 0.000201,
    -0.000201, 0.000201, -0.000201, 0.000202, -0.000202, 0.000202, -0.000202,
    0.000202, -0.000203, 0.000203, -0.000203, 0.000203, -0.000203, 0.000203,
    -0.000203, 0.000204, -0.000204, 0.000204, -0.000204, 0.000204, -0.000204,
    0.000204, -0.000204, 0.000204, -0.000204, 0.000204, -0.000204, 0.000204,
    -0.000204, 0.000204, -0.000204, 0.000204, -0.000204, 0.000204, -0.000204,
    0.000204,
  ],
  imag: [
    0.0, 0.292864, 0.0, 0.000002, -0.000001, 0.000001, -0.000001, 0.000001,
    -0.000002, 0.000002, -0.000002, 0.000002, -0.000002, 0.000003, -0.000003,
    0.000003, -0.000003, 0.000003, -0.000003, 0.000003, -0.000002, 0.0, -0.0,
    0.0, -0.0, 0.0, -0.0, 0.0, -0.0, 0.0, -0.0, 0.0, -0.0, 0.000003, -0.000003,
    0.000004, -0.000004, 0.000002, -0.000003, 0.000003, -0.000004, 0.000005,
    -0.000006, 0.000007, -0.000011, 0.000013, -0.000018, 0.000023, -0.000032,
    0.000037, -0.000044, 0.000053, -0.000055, 0.000058, -0.000055, 0.000056,
    -0.000049, 0.000043, -0.000036, 0.000025, -0.000024, 0.000017, -0.000018,
    0.000015, -0.000015, 0.000013, -0.000013, 0.000013, -0.000012, 0.000012,
    -0.000012, 0.000013, -0.000013, 0.000013, -0.000013, 0.000014, -0.000014,
    0.000018, -0.000019, 0.000019, -0.000021, 0.000021, -0.000022, 0.000024,
    -0.000024, 0.000025, -0.000029, 0.000029, -0.000031, 0.000031, -0.000033,
    0.000035, -0.000035, 0.000037, -0.000039, 0.00004, -0.000036, 0.000035,
    -0.000041, 0.000042, -0.000044, 0.000044, -0.00005, 0.000052, -0.000052,
    0.000052, -0.000054, 0.000054, -0.000054, 0.000056, -0.000056, 0.000056,
    -0.000058, 0.00006, -0.00006, 0.000062, -0.000062, 0.000062, -0.000064,
    0.000064, -0.000067, 0.000067, -0.000061, 0.000063, -0.000063, 0.000063,
    -0.000065, 0.000065, -0.000067, 0.000067, -0.000067, 0.000069, -0.000069,
    0.000071, -0.000071, 0.000071, -0.000073, 0.000073, -0.000073, 0.000074,
    -0.000076, 0.000073, -0.000075, 0.000075, -0.000077, 0.000077, -0.000079,
    0.000079, -0.000068, 0.000069, -0.000069, 0.000071, -0.000071, 0.000072,
    -0.000066, 0.000067, -0.000067, 0.000069, -0.000069, 0.000069, -0.00007,
    0.000066, -0.000067, 0.000067, -0.000069, 0.000069, -0.00007, 0.00007,
    -0.000067, 0.000067, -0.000068, 0.000068, -0.000069, 0.000069, -0.000066,
    0.000066, -0.000068, 0.000068, -0.000069, 0.000069, -0.000068, 0.000068,
    -0.000069, 0.000069, -0.000053, 0.000053, -0.000054, 0.000054, -0.000055,
    0.000055, -0.000056, 0.000056, -0.000049, 0.000049, -0.000049, 0.000049,
    -0.00005, 0.000049, -0.000049, 0.000049, -0.000046, 0.000046, -0.000046,
    0.000046, -0.000041, 0.000041, -0.000042, 0.000043, -0.000074, 0.000075,
    -0.000075, 0.000076, -0.000076, 0.000077, -0.000052, 0.000052, -0.000053,
    0.000055, -0.000055, 0.000055, -0.000056, 0.000056, -0.000057, 0.000057,
    -0.000057, 0.000058, -0.000058, 0.000058, -0.000059, 0.000059, -0.000063,
    0.000064, -0.000064, 0.000065, -0.000065, 0.000065, -0.000066, 0.000066,
    -0.000067, 0.000067, -0.000067, 0.000068, -0.000068, 0.000069, -0.000069,
    0.00007, -0.00007, 0.00007, -0.000071, 0.000071, -0.000072, 0.000079,
    -0.00008, 0.00008, -0.000081, 0.000081, -0.000084, 0.000085, -0.000085,
    0.000086, -0.000086, 0.000087, -0.000087, 0.000088, -0.000088, 0.000088,
    -0.000089, 0.00009, -0.00009, 0.000091, -0.000091, 0.000092, -0.000092,
    0.000092, -0.000093, 0.000094, -0.000094, 0.000095, -0.000095, 0.000096,
    -0.000096, 0.000097, -0.000097, 0.000098, -0.000098, 0.000096, -0.000096,
    0.000097, -0.000097, 0.000098, -0.000098, 0.000096, -0.000096, 0.000097,
    -0.000097, 0.000098, -0.000098, 0.000099, -0.000099, 0.0001, -0.0001,
    0.000101, -0.000101, 0.000102, -0.000102, 0.000103, -0.000103, 0.000104,
    -0.000104, 0.000105, -0.000105, 0.000106, -0.000106, 0.000107, -0.000107,
    0.000108, -0.000108, 0.000109, -0.000109, 0.00011, -0.00011, 0.000111,
    -0.000111, 0.000112, -0.000112, 0.000113, -0.000113, 0.000114, -0.000114,
    0.000115, -0.000115, 0.000116, -0.000116, 0.000117, -0.000118, 0.000118,
    -0.000119, 0.000119, -0.00012, 0.00012, -0.000121, 0.000121, -0.000122,
    0.000122, -0.000123, 0.000123, -0.000128, 0.000128, -0.000129, 0.000129,
    -0.00013, 0.00013, -0.000131, 0.000131, -0.000132, 0.000133, -0.000133,
    0.000134, -0.000134, 0.000135, -0.000135, 0.000136, -0.000136, 0.000137,
    -0.000138, 0.000138, -0.000139, 0.000139, -0.00014, 0.00014, -0.000141,
    0.000142, -0.000142, 0.000143, -0.000143, 0.000144, -0.000144, 0.000145,
    -0.000145, 0.000146, -0.000147, 0.000147, -0.000148, 0.000148, -0.000149,
    0.000149, -0.00015, 0.000151, -0.000151, 0.000152, -0.000152, 0.000153,
    -0.000153, 0.000154, -0.000155, 0.000155, -0.000156, 0.000156, -0.000157,
    0.000158, -0.000158, 0.000159, -0.000159, 0.00016, -0.00016, 0.000161,
    -0.000162, 0.000162, -0.000163, 0.000163, -0.000164, 0.000164, -0.000165,
    0.000166, -0.000161, 0.000162, -0.000162, 0.000163, -0.000163, 0.000164,
    -0.000165, 0.000165, -0.000166, 0.000166, -0.000167, 0.000168, -0.000168,
    0.000169, -0.000169, 0.00017, -0.00017, 0.000171, -0.000171, 0.000172,
    -0.000173, 0.000173, -0.000174, 0.000174, -0.000175, 0.000176, -0.000176,
    0.000177, -0.000177, 0.000178, -0.000179, 0.000179, -0.00018, 0.00018,
    -0.000181, 0.000181, -0.000182, 0.000182, -0.000183, 0.000184, -0.000184,
    0.000185, -0.000185, 0.000186, -0.000187, 0.000187, -0.000188, 0.000188,
    -0.000189, 0.00019, -0.00019, 0.000191, -0.000191, 0.000192, -0.000192,
    0.000193, -0.000194, 0.000194, -0.000195, 0.000195, -0.000196, 0.000197,
    -0.000197, 0.000198, -0.000198, 0.000199, -0.0002, 0.0002, -0.000201,
    0.000201, -0.000173, 0.000174, -0.000174, 0.000175, -0.000175, 0.000176,
    -0.000176, 0.000177, -0.000177, 0.000178, -0.000178, 0.000179, -0.000179,
    0.00018, -0.00018, 0.000181, -0.000181, 0.000182, -0.000182, 0.000183,
    -0.000183, 0.000184, -0.000184, 0.000185, -0.000185, 0.000186, -0.000186,
    0.000187, -0.000187, 0.000188, -0.000188, 0.000189, -0.00019, 0.00019,
    -0.000191, 0.000191, -0.000192, 0.000192, -0.000193, 0.000193, -0.000194,
    0.000194, -0.000195, 0.000195, -0.000196, 0.000196, -0.000197, 0.000197,
    -0.000198, 0.000198, -0.000199, 0.000199, -0.0002, 0.0002, -0.000201,
    0.000201, -0.000202, 0.000202, -0.000203, 0.000203, -0.000204, 0.000204,
    -0.000205, 0.000205, -0.000206, 0.000206, -0.000207, 0.000207, -0.000208,
    0.000208, -0.000209, 0.000209, -0.00021, 0.00021, -0.000211, 0.000211,
    -0.000212, 0.000213, -0.000213, 0.000213, -0.000214, 0.000215, -0.000215,
    0.000216, -0.000216, 0.000217, -0.000217, 0.000218, -0.000218, 0.000219,
    -0.000219, 0.00022, -0.00022, 0.000221, -0.000221, 0.000222, -0.000222,
    0.000223, -0.000223, 0.000224, -0.000224, 0.000225, -0.000225, 0.000226,
    -0.000226, 0.000227, -0.000227, 0.000201, -0.000202, 0.000202, -0.000203,
    0.000203, -0.000204, 0.000204, -0.000205, 0.000205, -0.000205, 0.000206,
    -0.000206, 0.000207, -0.000207, 0.000208, -0.000208, 0.000209, -0.000209,
    0.00021, -0.00021, 0.00021, -0.000211, 0.000211, -0.000212, 0.000212,
    -0.000213, 0.000213, -0.000214, 0.000214, -0.000214, 0.000215, -0.000215,
    0.000216, -0.000216, 0.000217, -0.000217, 0.000218, -0.000218, 0.000218,
    -0.000219, 0.000219, -0.00022, 0.00022, -0.000221, 0.000221, -0.000221,
    0.000222, -0.000222, 0.000223, -0.000223, 0.000224, -0.000224, 0.000224,
    -0.000225, 0.000225, -0.000226, 0.000226, -0.000227, 0.000227, -0.000227,
    0.000228, -0.000228, 0.000229, -0.000229, 0.00023, -0.00023, 0.00023,
    -0.000231, 0.000231, -0.000232, 0.000232, -0.000233, 0.000233, -0.000234,
    0.000234, -0.000234, 0.000235, -0.000235, 0.000236, -0.000236, 0.000236,
    -0.000237, 0.000237, -0.000238, 0.000238, -0.000238, 0.000239, -0.000239,
    0.00024, -0.00024, 0.000226, -0.000227, 0.000227, -0.000227, 0.000228,
    -0.000228, 0.000229, -0.000229, 0.000229, -0.00023, 0.00023, -0.00023,
    0.000231, -0.000231, 0.000232, -0.000232, 0.000232, -0.000233, 0.000233,
    -0.000234, 0.000234, -0.000234, 0.000235, -0.000235, 0.000235, -0.000236,
    0.000236, -0.000237, 0.000237, -0.000237, 0.000238, -0.000238, 0.000238,
    -0.000239, 0.000239, -0.000239, 0.00024, -0.00024, 0.000241, -0.000241,
    0.000241, -0.000242, 0.000242, -0.000242, 0.000243, -0.000243, 0.000243,
    -0.000244, 0.000244, -0.000244, 0.000245, -0.000245, 0.000246, -0.000246,
    0.000246, -0.000247, 0.000247, -0.000247, 0.000248, -0.000248, 0.000248,
    -0.000249, 0.000249, -0.000249, 0.00025, -0.00025, 0.00025, -0.000251,
    0.000251, -0.000251, 0.000252, -0.000252, 0.000252, -0.000253, 0.000253,
    -0.000253, 0.000254, -0.000254, 0.000254, -0.000255, 0.000255, -0.000255,
    0.000256, -0.000256, 0.000256, -0.000257, 0.000257, -0.000257, 0.000258,
    -0.000258, 0.000258, -0.000259, 0.000259, -0.000259, 0.00026, -0.00026,
    0.00026, -0.00026, 0.000261, -0.000261, 0.000231, -0.000231, 0.000232,
    -0.000232, 0.000232, -0.000232, 0.000233, -0.000233, 0.000233, -0.000234,
    0.000234, -0.000234, 0.000234, -0.000235, 0.000235, -0.000235, 0.000235,
    -0.000236, 0.000236, -0.000236, 0.000236, -0.000237, 0.000237, -0.000237,
    0.000237, -0.000238, 0.000238, -0.000238, 0.000238, -0.000239, 0.000239,
    -0.000239, 0.000239, -0.000239, 0.00024, -0.00024, 0.00024, -0.00024,
    0.000241, -0.000241, 0.000241, -0.000241, 0.000242, -0.000242, 0.000242,
    -0.000242, 0.000242, -0.000243, 0.000243, -0.000243, 0.000243, -0.000244,
    0.000244, -0.000244, 0.000244, -0.000244, 0.000245, -0.000245, 0.000245,
    -0.000245, 0.000245, -0.000246, 0.000246, -0.000246, 0.000246, -0.000246,
    0.000247, -0.000247, 0.000247, -0.000247, 0.000247, -0.000248, 0.000248,
    -0.000248, 0.000248, -0.000248, 0.000248, -0.000249, 0.000249, -0.000249,
    0.000249, -0.000249, 0.000249, -0.00025, 0.00025, -0.00025, 0.00025,
    -0.00025, 0.00025, -0.000251, 0.000251, -0.000251, 0.000251, -0.000251,
    0.000251, -0.000252, 0.000252, -0.000252, 0.000252, -0.000252, 0.000252,
    -0.000252, 0.000253, -0.000253, 0.000253, -0.000253, 0.000253, -0.000253,
    0.000253, -0.000254, 0.000254, -0.000254, 0.000254, -0.000254, 0.000254,
    -0.000254, 0.000254, -0.000255, 0.000255, -0.000255, 0.000255, -0.000255,
    0.000255, -0.000255, 0.000255, -0.000255, 0.000256, -0.000256, 0.000256,
    -0.000256, 0.000256, -0.000256, 0.000256, -0.000256, 0.000256, -0.000256,
    0.000257, -0.000257, 0.000257, -0.000257, 0.000257, -0.000257, 0.000257,
    -0.000257, 0.000257, -0.000257, 0.000257, -0.000257, 0.000257, -0.000258,
    0.000258, -0.000258, 0.000258, -0.000258, 0.000258, -0.000258, 0.000258,
    -0.000258, 0.000258, -0.000258, 0.000258, -0.000258, 0.000258, -0.000258,
    0.000258, -0.000258, 0.000258, -0.000258, 0.000258, -0.000258, 0.000259,
    -0.000259, 0.000259, -0.000259, 0.000251, -0.000251, 0.000251, -0.000251,
    0.000251, -0.000251, 0.000251, -0.000251, 0.000251, -0.000251, 0.000251,
    -0.000251, 0.000251, -0.000251, 0.000251, -0.000251, 0.000251, -0.000251,
    0.000251, -0.000251, 0.000251, -0.000251, 0.000251, -0.000251, 0.000251,
    -0.000251, 0.000251, -0.000251, 0.000251, -0.00025, 0.00025, -0.00025,
    0.00025, -0.00025, 0.00025, -0.00025, 0.00025, -0.00025, 0.00025, -0.00025,
    0.00025, -0.00025, 0.00025, -0.00025, 0.00025, -0.00025, 0.00025, -0.000249,
    0.000249, -0.000249, 0.000249, -0.000249, 0.000249, -0.000249, 0.000249,
    -0.000249, 0.000249, -0.000249, 0.000249, -0.000248, 0.000248, -0.000248,
    0.000248, -0.000248, 0.000248, -0.000248, 0.000248, -0.000248, 0.000247,
    -0.000247, 0.000247, -0.000247, 0.000247, -0.000247, 0.000247, -0.000247,
    0.000246, -0.000246, 0.000246, -0.000246, 0.000246, -0.000246, 0.000246,
    -0.000245, 0.000245, -0.000245, 0.000245, -0.000245, 0.000245, -0.000245,
    0.000244, -0.000244, 0.000244, -0.000244, 0.000244, -0.000243, 0.000243,
    -0.000243, 0.000243, -0.000243, 0.000243, -0.000242, 0.000242, -0.000242,
    0.000242, -0.000242, 0.000241, -0.000241, 0.000241, -0.000241, 0.000241,
    -0.00024, 0.00024, -0.00024, 0.00024, -0.000239, 0.000239, -0.000239,
    0.000239, -0.000239, 0.000238, -0.000238, 0.000238, -0.000238, 0.000237,
    -0.000237, 0.000237, -0.000237, 0.000236, -0.000236, 0.000236, -0.000236,
    0.000235, -0.000235, 0.000235, -0.000235, 0.000234, -0.000234, 0.000234,
    -0.000233, 0.000233, -0.000233, 0.000233, -0.000232, 0.000232, -0.000232,
    0.000231, -0.000231, 0.000231, -0.000231, 0.00023, -0.00023, 0.00023,
    -0.000229, 0.000229, -0.000229, 0.000228, -0.000228, 0.000228, -0.000227,
    0.000227, -0.000227, 0.000226, -0.000226, 0.000226, -0.000225, 0.000225,
    -0.000225, 0.000224, -0.000224, 0.000224, -0.000223, 0.000223, -0.000223,
    0.000222, -0.000222, 0.000222, -0.000221, 0.000221, -0.00022, 0.00022,
    -0.00022, 0.000219, -0.000219, 0.000218, -0.000218, 0.000218, -0.000217,
    0.000217, -0.000217, 0.000216, -0.000216, 0.000215, -0.000215, 0.000214,
    -0.000214, 0.000214, -0.000213, 0.000213, -0.000212, 0.000212, -0.000212,
    0.000211, -0.000211, 0.00021, -0.00021, 0.000209, -0.000209, 0.000209,
    -0.000208, 0.000208, -0.000207, 0.000207, -0.000206, 0.000206, -0.000205,
    0.000205, -0.000204, 0.000204, -0.000203, 0.000203, -0.000203, 0.000202,
    -0.000202, 0.000201, -0.000201, 0.0002, -0.0002, 0.000199, -0.000199,
    0.000198, -0.000198, 0.000197, -0.000197, 0.000196, -0.000196, 0.000195,
    -0.000195, 0.000194, -0.000194, 0.000193, -0.000193, 0.000192, -0.000191,
    0.000191, -0.00019, 0.00019, -0.000189, 0.000189, -0.000188, 0.000188,
    -0.000187, 0.000187, -0.000186, 0.000185, -0.000185, 0.000184, -0.000184,
    0.000183, -0.000183, 0.000182, -0.000182, 0.000181, -0.00018, 0.00018,
    -0.000179, 0.000179, -0.000178, 0.000177, -0.000177, 0.000176, -0.000176,
    0.000175, -0.000175, 0.000174, -0.000173, 0.000173, -0.000172, 0.000172,
    -0.000171, 0.00017, -0.00017, 0.000169, -0.000168, 0.000168, -0.000167,
    0.000167, -0.000166, 0.000165, -0.000165, 0.000164, -0.000163, 0.000163,
    -0.000162, 0.000161, -0.000161, 0.00016, -0.00016, 0.000159, -0.000158,
    0.000158, -0.000157, 0.000156, -0.000156, 0.000155, -0.000154, 0.000154,
    -0.000153, 0.000152, -0.000152, 0.000151, -0.00015, 0.000149, -0.000149,
    0.000148, -0.000147, 0.000147, -0.000155, 0.000155, -0.000154, 0.000153,
    -0.000152, 0.000152, -0.000151, 0.00015, -0.000149, 0.000149, -0.000148,
    0.000147, -0.000146, 0.000145, -0.000145, 0.000144, -0.000143, 0.000142,
    -0.000142, 0.000141, -0.00014, 0.000139, -0.000139, 0.000138, -0.000137,
    0.000136, -0.000135, 0.000135, -0.000134, 0.000133, -0.000132, 0.000131,
    -0.000131, 0.00013, -0.000129, 0.000128, -0.000127, 0.000127, -0.000126,
    0.000125, -0.000124, 0.000123, -0.000122, 0.000122, -0.000121, 0.00012,
    -0.000119, 0.000118, -0.000117, 0.000117, -0.000116, 0.000115, -0.000114,
    0.000113, -0.000112, 0.000111, -0.000111, 0.00011, -0.000109, 0.000108,
    -0.000107, 0.000107, -0.000106, 0.000105, -0.000104, 0.000103, -0.000102,
    0.000101, -0.0001, 0.0001, -0.000099, 0.000098, -0.000097, 0.000096,
    -0.000095, 0.000094, -0.000093, 0.000093, -0.000092, 0.000091, -0.00009,
    0.000089, -0.000088, 0.000087, -0.000086, 0.000085, -0.000085, 0.000084,
    -0.000083, 0.000082, -0.000081, 0.00008, -0.000079, 0.000078, -0.000077,
    0.000077, -0.000076, 0.000075, -0.000074, 0.000073, -0.000072, 0.000071,
    -0.00007, 0.000069, -0.000068, 0.000067, -0.000066, 0.000065, -0.000065,
    0.000064, -0.000063, 0.000062, -0.000061, 0.00006, -0.000059, 0.000058,
    -0.000057, 0.000056, -0.000055, 0.000054, -0.000053, 0.000052, -0.000052,
    0.000051, -0.00005, 0.000049, -0.000048, 0.000047, -0.000046, 0.000045,
    -0.000044, 0.000043, -0.000042, 0.000041, -0.00004, 0.000039, -0.000038,
    0.000037, -0.000036, 0.000035, -0.000035, 0.000034, -0.000033, 0.000032,
    -0.000031, 0.00003, -0.000029, 0.000028, -0.000027, 0.000026, -0.000025,
    0.000024, -0.000023, 0.000022, -0.000021, 0.00002, -0.000019, 0.000018,
    -0.000017, 0.000016, -0.000015, 0.000015, -0.000014, 0.000013, -0.000012,
    0.000011, -0.00001, 0.000009, -0.000008, 0.000007, -0.000006, 0.000005,
    -0.000004, 0.000003, -0.000002, 0.000001, -0.0, -0.000001, 0.000002,
    -0.000003, 0.000004, -0.000005, 0.000006, -0.000007, 0.000008, -0.000008,
    0.000009, -0.00001, 0.000011, -0.000012, 0.000013, -0.000014, 0.000015,
    -0.000016, 0.000017, -0.000018, 0.000019, -0.00002, 0.000021, -0.000022,
    0.000023, -0.000024, 0.000025, -0.000026, 0.000027, -0.000028, 0.000029,
    -0.00003, 0.000031, -0.000031, 0.000032, -0.000033, 0.000034, -0.000035,
    0.000036, -0.000037, 0.000038, -0.000039, 0.00004, -0.000041, 0.000042,
    -0.000043, 0.000044, -0.000045, 0.000046, -0.000047, 0.000047, -0.000048,
    0.000049, -0.00005, 0.000051, -0.000052, 0.000053, -0.000054, 0.000055,
    -0.000056, 0.000057, -0.000058, 0.000059, -0.00006, 0.000061, -0.000061,
    0.000062, -0.000063, 0.000064, -0.000065, 0.000066, -0.000067, 0.000068,
    -0.000069, 0.00007, -0.000071, 0.000072, -0.000072, 0.000073, -0.000074,
    0.000075, -0.000076, 0.000077, -0.000078, 0.000079, -0.00008, 0.00008,
    -0.000081, 0.000082, -0.000083, 0.000084, -0.000085, 0.000086, -0.000087,
    0.000088, -0.000088, 0.000089, -0.00009, 0.000091, -0.000092, 0.000093,
    -0.000094, 0.000094, -0.000095, 0.000096, -0.000097, 0.000098, -0.000099,
    0.0001, -0.0001, 0.000101, -0.000102, 0.000103, -0.000104, 0.000105,
    -0.000105, 0.000106, -0.000107, 0.000108, -0.000109, 0.00011, -0.00011,
    0.000111, -0.000112, 0.000113, -0.000114, 0.000115, -0.000115, 0.000116,
    -0.000117, 0.000118, -0.000119, 0.000119, -0.00012, 0.000121, -0.000122,
    0.000122, -0.000123, 0.000124, -0.000125, 0.000126, -0.000126, 0.000127,
    -0.000128, 0.000129, -0.000129, 0.00013, -0.000131, 0.000132, -0.000132,
    0.000133, -0.000134, 0.000135, -0.000135, 0.000136, -0.000137, 0.000138,
    -0.000138, 0.000139, -0.00014, 0.00014, -0.000141, 0.000142, -0.000142,
    0.000143, -0.000144, 0.000145, -0.000145, 0.000146, -0.000147, 0.000147,
    -0.000148, 0.000149, -0.000149, 0.00015, -0.000151, 0.000151, -0.000152,
    0.000153, -0.000153, 0.000154, -0.000155, 0.000155, -0.000156, 0.000156,
    -0.000157, 0.000158, -0.000158, 0.000159, -0.00016, 0.00016, -0.000161,
    0.000161, -0.000162, 0.000162, -0.000163, 0.000164, -0.000164, 0.000165,
    -0.000165, 0.000166, -0.000167, 0.000167, -0.000168, 0.000168, -0.000169,
    0.000169, -0.00017, 0.00017, -0.000171, 0.000171, -0.000172, 0.000172,
    -0.000173, 0.000173, -0.000174, 0.000174, -0.000175, 0.000175, -0.000176,
    0.000176, -0.000177, 0.000177, -0.000178, 0.000178, -0.000179, 0.000179,
    -0.00018, 0.00018, -0.000181, 0.000181, -0.000181, 0.000182, -0.000182,
    0.000183, -0.000183, 0.000184, -0.000184, 0.000184, -0.000185, 0.000185,
    -0.000186, 0.000186, -0.000186, 0.000187, -0.000187, 0.000187, -0.000188,
    0.000188, -0.000188, 0.000189, -0.000189, 0.00019, -0.00019, 0.00019,
    -0.00019, 0.000191, -0.000191, 0.000191, -0.000192, 0.000192, -0.000192,
    0.000193, -0.000193, 0.000193, -0.000193, 0.000194, -0.000194, 0.000194,
    -0.000194, 0.000195, -0.000195, 0.000195, -0.000195, 0.000196, -0.000196,
    0.000196, -0.000196, 0.000196, -0.000197, 0.000197, -0.000197, 0.000197,
    -0.000197, 0.000198, -0.000198, 0.000198, -0.000198, 0.000198, -0.000198,
    0.000199, -0.000199, 0.000199, -0.000199, 0.000199, -0.000199, 0.000199,
    -0.000199, 0.000199, -0.0002, 0.0002, -0.0002, 0.0002, -0.0002, 0.0002,
    -0.0002, 0.0002, -0.0002, 0.0002, -0.0002, 0.0002, -0.0002, 0.0002, -0.0002,
    0.0002, -0.0002, 0.0002, -0.0002, 0.0002, -0.0002, 0.0002, -0.0002, 0.0002,
    -0.0002, 0.0002, -0.0002, 0.0002, -0.0002, 0.0002, -0.0002, 0.0002, -0.0002,
    0.0002, -0.000199, 0.000199, -0.000199, 0.000199, -0.000199, 0.000199,
    -0.000199, 0.000199, -0.000199, 0.000198, -0.000198, 0.000198, -0.000198,
    0.000198, -0.000198, 0.000197, -0.000197, 0.000197, -0.000197, 0.000197,
    -0.000196, 0.000196, -0.000196, 0.000196, -0.000196, 0.000195, -0.000195,
    0.000195, -0.000195, 0.000194, -0.000194, 0.000194, -0.000193, 0.000193,
    -0.000193, 0.000193, -0.000192, 0.000192, -0.000192, 0.000191, -0.000191,
    0.000191, -0.00019, 0.00019, -0.00019, 0.000189, -0.000189, 0.000189,
    -0.000188, 0.000188, -0.000188, 0.000187, -0.000187, 0.000186, -0.000186,
    0.000186, -0.000185, 0.000185, -0.000184, 0.000184, -0.000183, 0.000183,
    -0.000183, 0.000182, -0.000182, 0.000181, -0.000181, 0.00018, -0.00018,
    0.000179, -0.000179, 0.000178, -0.000178, 0.000177, -0.000177, 0.000176,
    -0.000176, 0.000175, -0.000175, 0.000174, -0.000174, 0.000173, -0.000173,
    0.000172, -0.000171, 0.000171, -0.00017, 0.00017, -0.000169, 0.000168,
    -0.000168, 0.000167, -0.000167, 0.000166, -0.000165, 0.000165, -0.000164,
    0.000164, -0.000163, 0.000162, -0.000162, 0.000161, -0.00016, 0.00016,
    -0.000159, 0.000158, -0.000158, 0.000157, -0.000156, 0.000156, -0.000155,
    0.000154, -0.000153, 0.000153, -0.000152, 0.000151, -0.000151, 0.00015,
    -0.000149, 0.000148, -0.000148, 0.000147, -0.000146, 0.000145, -0.000145,
    0.000144, -0.000143, 0.000142, -0.000142, 0.000141, -0.00014, 0.000139,
    -0.000138, 0.000138, -0.000137, 0.000149, -0.000148, 0.000147, -0.000146,
    0.000145, -0.000144, 0.000144, -0.000143, 0.000142, -0.000141, 0.00014,
    -0.000139, 0.000138, -0.000137, 0.000136, -0.000135, 0.000134, -0.000133,
    0.000132, -0.000131, 0.00013, -0.000129, 0.000128, -0.000127, 0.000126,
    -0.000125, 0.000124, -0.000123, 0.000122, -0.000121, 0.00012, -0.000119,
    0.000118, -0.000117, 0.000116, -0.000115, 0.000114, -0.000113, 0.000112,
    -0.000111, 0.00011, -0.000108, 0.000107, -0.000106, 0.000105, -0.000104,
    0.000103, -0.000102, 0.000101, -0.0001, 0.000099, -0.000098, 0.000096,
    -0.000095, 0.000094, -0.000093, 0.000092, -0.000091, 0.00009, -0.000089,
    0.000087, -0.000086, 0.000085, -0.000084, 0.000083, -0.000082, 0.00008,
    -0.000079, 0.000078, -0.000077, 0.000076, -0.000075, 0.000074, -0.000072,
    0.000071, -0.00007, 0.000069, -0.000068, 0.000066, -0.000065, 0.000064,
    -0.000063, 0.000062, -0.000061, 0.000059, -0.000058, 0.000057, -0.000056,
    0.000054, -0.000053, 0.000052, -0.000051, 0.00005, -0.000048, 0.000047,
    -0.000046, 0.000045, -0.000043, 0.000042, -0.000041, 0.00004, -0.000039,
    0.000037, -0.000036, 0.000035, -0.000034, 0.000032, -0.000031, 0.00003,
    -0.000029, 0.000027, -0.000026, 0.000025, -0.000024, 0.000023, -0.000021,
    0.00002, -0.000019, 0.000018, -0.000016, 0.000015, -0.000014, 0.000013,
    -0.000011, 0.00001, -0.000009, 0.000008, -0.000006, 0.000005, -0.000004,
    0.000003, -0.000001,
  ],
};

const wavetable = {
  real: Float32Array.from(wavetableSource.real),
  imag: Float32Array.from(wavetableSource.imag),
};

    <script>

      // Before we do anything more, let's grab our checkboxes from the interface. We want to keep them in the groups they are in as each row represents a different sound or _voice_.
      const pads = document.querySelectorAll(".pads");

      const wave = new PeriodicWave(audioCtx, {
        real: wavetable.real,
        imag: wavetable.imag,
      });

      let attackTime = 0.2;
      const attackControl = document.querySelector("#attack");
      attackControl.addEventListener(
        "input",
        (ev) => {
          attackTime = parseFloat(ev.target.value);
        },
        false
      );

      let releaseTime = 0.5;
      const releaseControl = document.querySelector("#release");
      releaseControl.addEventListener(
        "input",
        (ev) => {
          releaseTime = parseFloat(ev.target.value);
        },
        false
      );

   
      // Expose frequency & frequency modulation
      let pulseHz = 880;
      const hzControl = document.querySelector("#hz");
      hzControl.addEventListener(
        "input",
        (ev) => {
          pulseHz = parseFloat(ev.target.value);
        },
        false
      );

      let lfoHz = 30;
      const lfoControl = document.querySelector("#lfo");
      lfoControl.addEventListener(
        "input",
        (ev) => {
          lfoHz = parseFloat(ev.target.value);
        },
        false
      );

      // Expose noteDuration & band frequency
      let noiseDuration = 1;
      const durControl = document.querySelector("#duration");
      durControl.addEventListener(
        "input",
        (ev) => {
          noiseDuration = parseFloat(ev.target.value);
        },
        false
      );

      let bandHz = 1000;
      const bandControl = document.querySelector("#band");
      bandControl.addEventListener(
        "input",
        (ev) => {
          bandHz = parseFloat(ev.target.value);
        },
        false
      );

      let playbackRate = 1;
      const rateControl = document.querySelector("#rate");
      rateControl.addEventListener(
        "input",
        (ev) => {
          playbackRate = parseFloat(ev.target.value);
        },
        false
      );

      const bpmControl = document.querySelector("#bpm");
      const bpmValEl = document.querySelector("#bpmval");

      bpmControl.addEventListener(
        "input",
        (ev) => 
        {
          let tempo = parseFloat(ev.target.value);
          bpmValEl.innerText = tempo;
          window.flutter_inappwebview.callHandler('bpmHandler', tempo);

        },
        false
      );

 
      // When the sample has loaded, allow play
      const loadingEl = document.querySelector(".loading");
      const playButton = document.querySelector("#playBtn");
      //let isPlaying = false;
      //setupSample().then((sample) => {
        //loadingEl.style.display = "none";

        //dtmf = sample; // to be used in our playSample function

        playButton.addEventListener("click", (ev) => 
        {
        

                  window.flutter_inappwebview.callHandler('playHandler', 'la plume de toto');
        },      false


        );
  </script>
  </body>
</html>


''';
}
