
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/provider/song_model_provider.dart';
import 'package:music_player/screen/now_playing.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class AllSongs extends StatefulWidget {
  const AllSongs({super.key});

  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // playSong(String? uri) {
  //   try {
  //     _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
  //     _audioPlayer.play();
  //   } on Exception {
  //     log("Error parsing song");
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();
  }

  void requestPermission() {
    Permission.storage.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Music Player"),
          centerTitle: true,
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search))
          ],
        ),
        body: FutureBuilder<List<SongModel>>(
          future: _audioQuery.querySongs(
              sortType: null,
              orderType: OrderType.ASC_OR_SMALLER,
              uriType: UriType.EXTERNAL,
              ignoreCase: true),
          builder: (context, item) {
            if (item.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (item.data!.isEmpty) {
              return const Text("No songs found");
            }
            return ListView.builder(
              itemCount: item.data!.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(item.data![index].displayNameWOExt),
                subtitle: Text("${item.data![index].artist}"),
                trailing: const Icon(Icons.more_horiz),
                leading: QueryArtworkWidget(
                  id: item.data![index].id,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: const Icon(Icons.music_note),
                ),
                onTap: (() {
                  context.read<SongModelProvider>().setId(item.data![index].id);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OnPlaying(
                                songModel: item.data![index],
                                audioPlayer: _audioPlayer,
                              )));
                }),
              ),
            );
          },
        ));
  }
}
