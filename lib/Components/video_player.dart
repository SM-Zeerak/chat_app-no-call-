// video_player_widget.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  VideoPlayerWidget({required this.url});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {}); // Refresh to show video player
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Stack(
            children: [
              Container(
                child: VideoPlayer(_controller),
              ),
              Positioned(
                top: MediaQuery.sizeOf(context).height * 0.04,
                left: MediaQuery.sizeOf(context).width * 0.18,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.black, width: 2)),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 30,
                      color: Colors.blue,
                    )),
              )
            ],
          )
        : Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
