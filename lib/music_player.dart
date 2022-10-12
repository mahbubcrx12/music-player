import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  bool isPlaying = false;
  double value = 0;
  //create an instance of audio player
  final player = AudioPlayer();

  //setting the duration
  Duration? duration;

  //create a function to initiate of the music player
  void initPlayer() async {
    await player.setSource(AssetSource("aushomapto.mp3"));
    duration = await player.getDuration();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("Music Player"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/cover.jpg"), fit: BoxFit.cover)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                color: Colors.black12,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image(
                  image: AssetImage(
                    "assets/cover.jpg",
                  ),
                  width: 250,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Aushomapto",
                style: TextStyle(
                    color: Colors.white, fontSize: 35, letterSpacing: 3),
              ),
              SizedBox(
                height: 45,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${(value / 60).floor()} : ${(value % 60).floor()}",
                    style: TextStyle(color: Colors.white),
                  ),
                  // Slider.adaptive(
                  //   value: value,
                  //   onChanged: (value) {},
                  //   activeColor: Colors.white,
                  // ),
                  // Text(
                  //   "${duration!.inMinutes} : ${duration!.inSeconds % 60}",
                  //   style: TextStyle(color: Colors.white),
                  // ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.blue),
                child: InkWell(
                  onTap: () async {
                    //to play the song
                    if (isPlaying) {
                      await player.pause();
                      isPlaying = false;
                    } else {
                      await player.resume();
                      isPlaying = true;

                      //lets track the value
                      player.onPositionChanged.listen(
                        (event) {
                          setState(() {
                            value = event.inSeconds.toDouble();
                          });
                        },
                      );
                    }
                  },
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
