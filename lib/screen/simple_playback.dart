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
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:flutter_sound/flutter_sound.dart';

/*
 *
 * This is a very simple example for Flutter Sound beginners,
 * that show how to record, and then playback a file.
 *
 * This example is really basic.
 *
 */

// final String _exampleAudioFilePathMP3 =
//     'https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3';
const String _exampleAudioFilePathMP3 =
    'https://www.jasidutonline.com/wp-content/uploads/2021/10/Hacerse-cargo-y-salir-victorioso..mp3';

///
typedef Fn = void Function();

/// Example app.
class SimplePlayback extends StatefulWidget {
  const SimplePlayback({Key? key}) : super(key: key);

  @override
  _SimplePlaybackState createState() => _SimplePlaybackState();
}

class _SimplePlaybackState extends State<SimplePlayback> {
  // FlutterSoundPlayer? _player = FlutterSoundPlayer(logLevel: Level.warning);
  bool _playerIsInited = false;
  StreamSubscription? _playerSubscription;
  Duration _progress = Duration.zero;
  Duration _duration = Duration.zero;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    _player.positionStream.listen((Duration? position) {
      _progress = position ?? _progress;
      if (_duration == _progress) {
        _paused();
      }
      setState(() {});
    });
    StreamSubscription _playerSubscription =
        _player.playbackEventStream.listen((event) {
      // duration = event.duration ?? duration;
      // _progress = event.bufferedPosition; //.position;
      // setState(() {});
    }, onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    // Try to load audio from a source and catch any errors.
    try {
      await _player.setUrl(_exampleAudioFilePathMP3);

      _player.load().then((Duration? value) {
        _duration = value ?? _duration;
        setState(() {
          _playerIsInited = true;
        });
      });
    } catch (e) {
      print("Error loading audio source: $e");
    }

    // FlutterSoundPlayer? flutterSoundPlayer =
    //     await _mPlayer!.openAudioSession(category: SessionCategory.playback);
    // if (flutterSoundPlayer != null) {
    //   await _play();
    //   await _paused();
    //   setState(() {
    //     _mPlayerIsInited = true;
    //   });

    //   _mPlayer!.setSubscriptionDuration(const Duration(milliseconds: 100));
    //   _mPlayerSubscription = _mPlayer!.onProgress!.listen((e) {
    //     duration = e.duration;
    //     progress = e.position;
    //     // setPos(e.position.inMilliseconds); //desfase de mas en el tiempo (otro archivo)
    //     setState(() {});
    //   });
    // }
  }

  @override
  void dispose() {
    _stopPlayer();
    _playerSubscription?.cancel();
    // Be careful : you must `close` the audio session when you have finished with it.
    _player.dispose();
    super.dispose();
  }

  // -------  Here is the code to playback a remote file -----------------------

  Future<void> _play() async {
    await _player.play();
    setState(() {});
  }

  Future<void> _paused() async {
    await _player.pause();
    setState(() {});
  }

  Future<void> _stopPlayer() async {
    await _player.stop();
  }

  Future<void> _seek(Duration duration) async {
    if (duration < Duration.zero) {
      //no negativo
      duration = Duration.zero;
    } else if (duration > _duration) {
      //no exedente
      duration = _duration;
      await _paused();
    }
    await _player.seek(duration);
  }

  // --------------------- UI -------------------

  Fn? getPlaybackFn() {
    if (!_playerIsInited) {
      return null;
    }
    return _player.playing ? _paused : _play;
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitHours = twoDigits(duration.inHours);
    // if (twoDigitMinutes == '00') {
    //   return twoDigitSeconds;
    // } else if (twoDigitHours == '00') {
    //   return "$twoDigitMinutes:$twoDigitSeconds";
    // }
    return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Playback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(_printDuration(_progress)),
            //     Text("-${_printDuration(_duration - _progress)}"),
            //   ],
            // ),
            ProgressBar(
              progress: _progress,
              total: _duration,
              onSeek: _seek,
              timeLabelLocation: TimeLabelLocation.above,
              timeLabelType: TimeLabelType.remainingTime,
              timeLabelPadding: 10,
            ),
            // PlaybarSlider(_player.playbackEventStream, _seek, null),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () async {
                    await _seek(_progress - const Duration(seconds: 10));
                  },
                  icon: const Icon(Icons.replay_10_rounded),
                  color: Colors.redAccent,
                  padding: EdgeInsets.zero,
                  iconSize: 50,
                ),
                IconButton(
                  onPressed: getPlaybackFn(),
                  icon: Icon(
                    !_player.playing ? Icons.play_arrow_rounded : Icons.pause,
                  ),
                  iconSize: 80,
                ),
                IconButton(
                  onPressed: () async {
                    await _seek(_progress + const Duration(seconds: 30));
                  },
                  icon: const Icon(Icons.forward_30_rounded),
                  color: Colors.redAccent,
                  padding: EdgeInsets.zero,
                  iconSize: 50,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
