import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({Key? key}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final VideoPlayerController _controller;
  bool _controllerIsInited = false;
  Duration _progress = Duration.zero;
  Duration duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    // https://sample-videos.com/
    _controller = VideoPlayerController.network(
        'https://sample-videos.com/video123/mp4/480/big_buck_bunny_480p_30mb.mp4')
      ..addListener(() {
        _progress = _controller.value.position;
        duration = _controller.value.duration;
        setState(() {});
      })
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.

        setState(() {
          _controllerIsInited = true;
        });
      }).onError((error, stackTrace) {
        print(error);
        return;
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controllerIsInited
          ? videoPlayerBody()
          : const Center(
              child: CircularProgressIndicator(),
            ),
      /*FutureBuilder(
        future: _controller.initialize(),
        builder: (context, snapshot) {
          Widget _view;
          snapshot.connectionState == ConnectionState.done
              ? _view = videoPlayerBody()
              : _view = const Center(
                  child: CircularProgressIndicator(),
                );
          return _view;
        },
      ),
      */
    );
  }

  Widget videoPlayerBody() => Column(
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ProgressBar(
                  progress: _progress,
                  total: duration,
                  onSeek: _seek,
                  timeLabelLocation: TimeLabelLocation.above,
                  timeLabelType: TimeLabelType.remainingTime,
                  timeLabelPadding: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await _seek(_controller.value.position -
                            const Duration(seconds: 10));
                      },
                      icon: const Icon(Icons.replay_10_rounded),
                      color: Colors.redAccent,
                      padding: EdgeInsets.zero,
                      iconSize: 50,
                    ),
                    IconButton(
                      onPressed: getPlaybackFn(),
                      icon: Icon(
                        !_controller.value.isPlaying
                            ? Icons.play_arrow_rounded
                            : Icons.pause,
                      ),
                      iconSize: 80,
                      color: _controller.value.isPlaying
                          ? Colors.red
                          : Colors.blue,
                    ),
                    IconButton(
                      onPressed: () async {
                        await _seek(_controller.value.position +
                            const Duration(seconds: 30));
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
        ],
      );
  // ------------------------- controls ------------

  Future<void> _play() async {
    await _controller.play();
    setState(() {});
    return;
  }

  Future<void> _paused() async {
    await _controller.pause();
    setState(() {});
  }

  Future<void> _stopPlayer() async {
    await _controller.pause();
    await _controller.seekTo(Duration.zero);
  }

  Future<void> _seek(Duration duration) async {
    await _controller.seekTo(duration);
    setState(() {});
  }

  VoidCallback? getPlaybackFn() {
    if (!_controller.value.isInitialized) {
      return null;
    }
    return _controller.value.isPlaying ? _paused : _play;
  }
}
