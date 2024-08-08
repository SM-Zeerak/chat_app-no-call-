// fullscreen_media_viewer.dart

import 'package:chat_app_1/Components/video_player.dart';
import 'package:flutter/material.dart';

class FullscreenMediaViewer extends StatelessWidget {
  final String mediaUrl;
  final bool isVideo;

  FullscreenMediaViewer({required this.mediaUrl, required this.isVideo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isVideo ? 'Video' : 'Image'),
      ),
      body: Center(
        child: isVideo
            ? VideoPlayerWidget(url: mediaUrl)
            : Image.network(mediaUrl),
      ),
    );
  }
}
