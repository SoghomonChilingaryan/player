import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:player/src/features/album/ui/bloc/album_bloc.dart';
import 'package:player/src/features/mp3_player/ui/bloc/player_bloc.dart';
import 'package:player/src/features/mp3_player/ui/widgets/audio_progress_bar_widget.dart';
import 'package:player/src/features/mp3_player/ui/widgets/image_widget.dart';
import 'package:player/src/features/mp3_player/ui/widgets/play_pause_widget.dart';
import 'package:player/src/features/mp3_player/ui/widgets/rewind_button_widget.dart';
import 'package:player/src/features/mp3_player/ui/widgets/upper_buttons.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerBloc, PlayerState>(
    listenWhen: (previous, current) =>
        previous.album.albumPosition != current.album.albumPosition ||
        previous.album.albumDuration != current.album.albumDuration,
    listener: (context, state) {
      context
          .read<AlbumBloc>()
          .add(AlbumEvent.openAlbumFolder(album: state.album));
    },
    child:
     Scaffold(
      backgroundColor: Colors.grey[200],
      body: const SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child: ImageWidget()),
            UpperButtonsWidget(),
            Padding(
                padding: EdgeInsets.only(top: 10),
                child: AlbumProgressBarrWidget()),
            Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: TrackProgressBarrWidget()),
            RewindButtonsWidget(),
            SizedBox(height: 10),
            PlayPauseWidget()
          ],
        ),
      ),
      ),
    );
  }
}
