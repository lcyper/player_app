/*
 * Copyright 2018, 2019, 2020, 2021 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the Mozilla Public License version 2 (MPL2.0),
 * as published by the Mozilla organization.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
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
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:flutter_sound_lite/public/flutter_sound_player.dart';
// import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart' show Level, Logger;

/*
 *
 * This is a very simple example for Flutter Sound beginners,
 * that show how to record, and then playback a file.
 *
 * This example is really basic.
 *
 */

final _exampleAudioFilePathMP3 =
    'https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3';

///
typedef Fn = void Function();

/// Example app.
class SimplePlayback extends StatefulWidget {
  const SimplePlayback({Key? key}) : super(key: key);

  @override
  _SimplePlaybackState createState() => _SimplePlaybackState();
}

class _SimplePlaybackState extends State<SimplePlayback> {
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer(logLevel: Level.warning);
  bool _mPlayerIsInited = false;
  StreamSubscription? _mPlayerSubscription;
  Duration progress = Duration.zero;
  Duration duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    FlutterSoundPlayer? flutterSoundPlayer =
        await _mPlayer!.openAudioSession(category: SessionCategory.playback);
    if (flutterSoundPlayer != null) {
      setState(() {
        _mPlayerIsInited = true;
      });

      _mPlayer!.setSubscriptionDuration(const Duration(milliseconds: 100));
      _mPlayerSubscription = _mPlayer!.onProgress!.listen((e) {
        // setPos(e.position.inMilliseconds); //desfase de mas en el tiempo (otro archivo)
        setState(() {});
      });
      // var value = await _mPlayer!.getProgress();
      // print(value);
      // print('---');
      // progress = (await _mPlayer!.getProgress())['progress'] ?? Duration.zero;
      // duration = (await _mPlayer!.getProgress())['duration'] ?? Duration.zero;
      // _mPlayer?.setUIProgressBar();
      // _mPlayer?.getProgress();
    }
  }

  @override
  void dispose() {
    _stopPlayer();
    cancelPlayerSubscriptions();
    // Be careful : you must `close` the audio session when you have finished with it.
    _mPlayer!.closeAudioSession();
    _mPlayer = null;

    super.dispose();
  }

  void cancelPlayerSubscriptions() {
    if (_mPlayerSubscription != null) {
      _mPlayerSubscription!.cancel();
      _mPlayerSubscription = null;
    }
  }

  // -------  Here is the code to playback a remote file -----------------------

  void _play() async {
    if (_mPlayer != null && _mPlayer!.isPaused) {
      await _mPlayer!.resumePlayer();
      setState(() {});
      return;
    }
    await _mPlayer!.startPlayer(
        fromURI: _exampleAudioFilePathMP3,
        codec: Codec.mp3,
        whenFinished: () {
          setState(() {});
        });
    setState(() {});
  }

  void _paused() async {
    await _mPlayer?.pausePlayer();
    setState(() {});
  }

  Future<void> _stopPlayer() async {
    if (_mPlayer != null) {
      await _mPlayer!.stopPlayer();
    }
  }

  Future<void> _seek(Duration duration) async {
    await _mPlayer?.seekToPlayer(duration);
    // await setPos(d.floor());
  }

  // --------------------- UI -------------------

  Fn? getPlaybackFn() {
    if (!_mPlayerIsInited) {
      return null;
    }
    return _mPlayer!.isPlaying ? _paused : _play;
    //  () {

    //     _stopPlayer().then((value) => setState(() {}));
    //   };
  }

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Container(
        padding: const EdgeInsets.all(16),
        height: 100,
        width: double.infinity,
        alignment: Alignment.center,
        color: Colors.white,
        child: Row(
          children: [
            ElevatedButton(
              onPressed: getPlaybackFn(),
              child: Icon(!_mPlayer!.isPlaying
                  ? Icons.play_arrow_rounded
                  : Icons.pause), //Icons.stop_rounde
            ),

            Expanded(
              child: Column(
                children: [
                  PlaybarSlider(_mPlayer!.onProgress!, _seek, null),
                  Text('$progress/$duration'),
                ],
              ),
            ),
            // Text(_mPlayer!.isPlaying
            //     ? 'Playback in progress'
            //     : 'Player is stopped'),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Simple Playback'),
      ),
      body: makeBody(),
    );
  }
}
