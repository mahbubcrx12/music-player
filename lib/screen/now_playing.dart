import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/provider/song_model_provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class OnPlaying extends StatefulWidget {
  const OnPlaying(
      {super.key, required this.songModel, required this.audioPlayer});

  final SongModel songModel;
  final AudioPlayer audioPlayer;

  @override
  State<OnPlaying> createState() => _OnPlayingState();
}

class _OnPlayingState extends State<OnPlaying> {
  Duration _duration = const Duration();
  Duration _positioin = const Duration();
  bool _isPlaying = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playSong();
  }

  void playSong() {
    try {
      widget.audioPlayer.setAudioSource(AudioSource.uri(
        Uri.parse(widget.songModel.uri!),
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: "${widget.songModel.id}",
          // Metadata to display in the notification:
          album: "${widget.songModel.album}",
          title: "${widget.songModel.displayNameWOExt}",
          artUri: Uri.parse('https://example.com/albumart.jpg'),
        ),
      ));

      widget.audioPlayer.play();
      _isPlaying = true;
    } on Exception {
      log("can not parse song");
    }

    widget.audioPlayer.durationStream.listen((duration) {
      setState(() {
        _duration = duration!;
      });
    });
    widget.audioPlayer.positionStream.listen((position) {
      setState(() {
        _positioin = position;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios)),
              Center(
                child: Column(
                  children: [
                    Center(
                      child: const ArtWorkWidget(),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      widget.songModel.displayNameWOExt,
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.songModel.artist.toString() == "<unknown artist>"
                          ? "unknown Artist"
                          : widget.songModel.artist.toString(),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(_positioin.toString().split(".")[0]),
                        Expanded(
                            child: Slider(
                                min: Duration(microseconds: 0)
                                    .inSeconds
                                    .toDouble(),
                                max: _duration.inSeconds.toDouble(),
                                value: _positioin.inSeconds.toDouble(),
                                onChanged: ((value) {
                                  setState(() {
                                    changeToSeconds(value.toInt());
                                    value = value;
                                  });
                                }))),
                        Text(_duration.toString().split(".")[0]),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.skip_previous,
                              size: 40,
                            )),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                if (_isPlaying) {
                                  widget.audioPlayer.pause();
                                } else {
                                  widget.audioPlayer.play();
                                }
                                _isPlaying = !_isPlaying;
                              });
                            },
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 40,
                              color: Colors.blue,
                            )),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.skip_next,
                              size: 40,
                            ))
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void changeToSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);
  }
}

class ArtWorkWidget extends StatelessWidget {
  const ArtWorkWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      id: context.watch<SongModelProvider>().id,
      type: ArtworkType.AUDIO,
      artworkHeight: 200,
      artworkWidth: 200,
      artworkFit: BoxFit.cover,
      nullArtworkWidget: const Icon(
        Icons.music_note,
        size: 200,
      ),
    );
  }
}
