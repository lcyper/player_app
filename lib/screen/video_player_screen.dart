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
          ? OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.portrait) {
                  return _videoColumnPlayer();
                } else {
                  return _videoInFullScreen();
                }
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _videoInFullScreen() {
    return Column(
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
                    color:
                        _controller.value.isPlaying ? Colors.red : Colors.blue,
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
  }

  Widget _videoColumnPlayer() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        // mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 26,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.shiurInfo.rabino,
                      style: Theme.of(context).textTheme.button?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    Text(
                      widget.shiurInfo.titulo,
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipOval(
                      child: IconButton(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.expand_more),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        iconSize: 30,
                      ),
                    ),
                    ClipOval(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        splashColor: Colors.white,
                        onPressed: () async {
                          await context.read<PlayerCubit>().hide();
                          Navigator.pop(context);
                        },
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.close_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ClipRRect(
            child: Container(
              color: const Color.fromARGB(255, 240, 229, 215),
              width: double.infinity,
              height: 300,
              child: Center(
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: VideoPlayer(widget.playerController),
                  ),
                  // child: ClipRRect(
                  //   borderRadius: BorderRadius.circular(radiusCircular),
                  //   child: CachedNetworkImage(
                  //     imageUrl: widget.shiurInfo.profilePicture,
                  //     fit: BoxFit.cover,
                  //     height: 160,
                  //     width: 160,
                  //   ),
                  // ),
                ),
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: _progressBar(),
            ),
          ),
          Flexible(
            flex: 2,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: IconButton(
                        onPressed: () async {
                          await _seek(widget.playerController.value.position +
                              const Duration(seconds: 30));
                        },
                        icon: Image.asset(
                          'assets/icons/30_plus.png',
                          fit: BoxFit.scaleDown,
                        ),
                        padding: EdgeInsets.zero,
                        iconSize: 48,
                      ),
                    ),
                    Flexible(
                      child: IconButton(
                        onPressed: getPlaybackFn(),
                        icon: Icon(
                          !widget.playerController.value.isPlaying
                              ? Icons.play_arrow_rounded
                              : Icons.pause,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        iconSize: 79,
                      ),
                    ),
                    Flexible(
                      child: IconButton(
                        onPressed: () async {
                          await _seek(widget.playerController.value.position -
                              const Duration(seconds: 30));
                        },
                        icon: Image.asset(
                          'assets/icons/30_minus.png',
                          fit: BoxFit.scaleDown,
                        ),
                        padding: EdgeInsets.zero,
                        iconSize: 48,
                      ),
                    ),
                  ],
                ),
                _speedSelector(),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
