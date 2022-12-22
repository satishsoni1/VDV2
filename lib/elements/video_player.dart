import 'package:blog_app/models/blog_category.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as convert;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class CustomVideoPlayer extends StatefulWidget {
  final DataModel? blog;
  CustomVideoPlayer({Key? key, this.blog}) : super(key: key);

  @override
  CustomVideoPlayerState createState() => CustomVideoPlayerState();
}

class CustomVideoPlayerState extends State<CustomVideoPlayer> {
  YoutubePlayerController? controller;
  @override
  void initState() {
    super.initState();
    final videoId = convert.YoutubePlayer.convertUrlToId(
      widget.blog!.videoUrl.toString(),
    );
    controller = YoutubePlayerController(
      //initialVideoId: videoId.toString(),
      params: const YoutubePlayerParams(
        mute: false,
        autoPlay: true,
        enableJavaScript: false,
        enableCaption: false,
        //  desktopMode: false,
        showControls: true,
      ),
    );
    controller?.playVideo();
  }

  vidoPlayPauseTogal(bool isPause) {
    if (isPause) {
      setState(() {
        print("object stop");
        controller?.stopVideo();
      });
    } else {
      controller?.stopVideo();
      print("object play");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width,
      child: YoutubePlayerIFrame(
        controller: controller,
        aspectRatio: 16 / 9,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller?.pauseVideo();
  }

  @override
  void deactivate() {
    super.deactivate();
    controller?.pauseVideo();
  }

  @override
  void dispose() {
    super.dispose();
    if (controller != null) controller?.close();
  }
}
