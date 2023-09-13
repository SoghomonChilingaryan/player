import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:player/src/common/navigation/routs_name.dart';
import 'package:player/src/common/res/app_assets.dart';
import 'package:player/src/common/res/app_button_style.dart';
import 'package:player/src/features/mp3_player/ui/bloc/player_bloc.dart';
import 'package:player/src/features/splash/ui/bloc/splash_bloc.dart';
import 'package:player/src/features/tracks/ui/bloc/track_bloc.dart';

class TrackListScreen extends StatelessWidget {
  const TrackListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music'),
      ),
      body: SafeArea(
        child: BlocConsumer<TrackBloc, TrackState>(
          listener: (context, state) {},
          builder: (context, state) {
            return state.map(
              loading: (state) =>
                  const Center(child: CircularProgressIndicator()),
              empty: (state) => const Center(child: Text('Empty')),
              loaded: (state) => ListView.separated(
                itemCount: state.album.tracks.length,
                itemBuilder: (context, index) {
                  final track = state.album.tracks[index];
                  final artwork = state.artworks[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 6,
                          child: GestureDetector(
                            onTap: () {
                              context.read<PlayerBloc>().add(
                                  PlayerEvent.addTrack(
                                      track: track, album: state.album));
                              // context.go(AppRouts.playerScreen);
                              Navigator.of(context).pushReplacementNamed(AppRouts.playerScreen);
                              context
                                  .read<SplashBloc>()
                                  .add(const SplashEvent.playing());
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: artwork.isNotEmpty
                                      ? Image.memory(
                                          Uint8List.fromList(artwork))
                                      : const Image(
                                          image:
                                              AssetImage(AppAssets.shortwave),
                                        ),
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${track.artist}',
                                            style:
                                                const TextStyle(fontSize: 20),
                                            maxLines: 1),
                                        const Divider(),
                                        Text(('${track.name}'),
                                            style:
                                                const TextStyle(fontSize: 18),
                                            maxLines: 2),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: TextButton(
                            onPressed: () {},
                            style: AppButtonStyle.moreVert,
                            child: const Icon(Icons.more_vert),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              ),
            );
          },
        ),
      ),
    );
  }
}