import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const Home());

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: PageView(
          scrollDirection: Axis.vertical,
          controller: PageController(initialPage: 0),
          children: const [
            VideoApp(
              url: 'http://141.164.50.18:3333/poong.mp4',
              id: '0',
            ),
            VideoApp(url: 'http://141.164.50.18:3333/chimps.mp4', id: '1'),
            VideoApp(url: 'http://141.164.50.18:3333/zelda.mp4', id: '2'),
            VideoApp(url: 'http://141.164.50.18:3333/cat.mp4', id: '3'),
          ],
        ),
      ),
    );
  }
}

/// Stateful widget to fetch and then display video content.
class VideoApp extends StatefulWidget {
  const VideoApp({super.key, required this.url, required this.id});

  final String url;
  final String id;

  @override
  VideoAppState createState() => VideoAppState();
}

class VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          _controller.play();
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : SizedBox(
                  width: MediaQuery.of(context).size.height,
                  height: MediaQuery.of(context).size.height,
                ),
        ),
        Row(
          children: [
            Flexible(
              flex: 5,
              child: Container(),
            ),
            Flexible(
              flex: 1,
              child: Column(
                children: [
                  Flexible(
                    flex: 3,
                    child: Container(),
                  ),
                  Flexible(
                    child: ButtonWithNum(id: widget.id),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class ButtonWithNum extends StatefulWidget {
  const ButtonWithNum({super.key, required this.id});
  final String id;
  @override
  State<ButtonWithNum> createState() => _ButtonWithNumState();
}

class _ButtonWithNumState extends State<ButtonWithNum> {
  late String like = '0';

  @override
  void initState() {
    super.initState();

    final url = Uri.parse('http://141.164.50.18:3334/like/${widget.id}');
    http.get(url).then((value) {
      like = value.body;
    });
  }

  void onLikeClicked() {
    setState(() {
      final url = Uri.parse('http://141.164.50.18:3334/up/${widget.id}');
      http.get(url).then((value) {
        like = value.body;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onLikeClicked,
          icon: Icon(
            Icons.favorite_border,
            color: Colors.pink[300],
            size: 30,
          ),
        ),
        Text(
          like,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        )
      ],
    );
  }
}
