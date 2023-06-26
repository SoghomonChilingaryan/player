// ignore: depend_on_referenced_packages
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:player/src/features/album/domain/entities/album.dart';
import 'package:player/src/features/mp3_player/domain/player_repository.dart';
import 'package:player/src/features/track_list/domain/entities/track.dart';

part 'player_event.dart';
part 'player_state.dart';

part 'player_bloc.freezed.dart';
part 'player_bloc.g.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> with HydratedMixin {
  final IAudioPlayerRepository _playerRepository;
  PlayerBloc({required IAudioPlayerRepository playerRepository})
      : _playerRepository = playerRepository,
        super(const PlayerState()) {
    _playerRepository.positionStream.listen((event) async {
      // await Future.delayed(const Duration(microseconds: 100));
      add(PlayerEvent.changeTrackPositionInSeconds(position: event));
    }, cancelOnError: false);

    on<PlayerEvent>((event, emit) async {
      await event.map<Future<void>>(
        initial: (event) => _initial(event, emit),
        addMusic: (event) => _addMusic(event, emit),
        play: (event) => _playEvent(event, emit),
        pause: (event) => _pauseEvent(event, emit),
        prev: (event) => _prevTrack(event, emit),
        next: (event) => _nextTrack(event, emit),
        rewind: (event) => _rewind(event, emit),
        push: (event) => _push(event, emit),
        changeTrackPositionInSeconds: (event) =>
            _changeTrackPositionInSeconds(event, emit),
        changeTrackProgressBar: (event) => _changeTrackProgressBar(event, emit),
        changeAlbumProgressBar: (event) => _changeAlbumProgressBar(event, emit),
        changeState: (event) => _changeState(event, emit),
      );
    });
  }

  Future<void> _initial(
      _PlayerInitialEvent event, Emitter<PlayerState> emit) async {
    if (state.status == PlayerStatus.initial) {
      return;
    } else {
      emit(state.copyWith(status: PlayerStatus.paused));
      _playerRepository.addMusicDirectory(
        tracks: state.album.tracks,
        trackPosition: state.trackPosition,
        trackIndex: state.trackIndex,
      );
    }
  }

  Future<void> _addMusic(
      _PlayerAddMusicEvent event, Emitter<PlayerState> emit) async {
    _playerRepository.addMusicDirectory(
      tracks: event.album.tracks,
      trackIndex: event.track.index,
      trackPosition: event.track.position,
    );
    final mapAlbumDuration = _playerRepository.getMapAlbumDuration;
    final albumDuration = _playerRepository.albumDuration;
    final artwork =
        await _playerRepository.getArtwork(index: event.track.index);
    emit(state.copyWith(
      artwork: artwork,
      album: event.album.copyWith(albumDuration: albumDuration),
      mapAlbumDuration: mapAlbumDuration,
    ));
    add(const PlayerEvent.play());
  }

  Future<void> _playEvent(
      _PlayerPlayEvent event, Emitter<PlayerState> emit) async {
    _playerRepository.play();
    emit(state.copyWith(status: PlayerStatus.playing));
  }

  Future<void> _pauseEvent(
      _PlayerPauseEvent event, Emitter<PlayerState> emit) async {
    _playerRepository.pause();
    emit(state.copyWith(status: PlayerStatus.paused));
  }

  Future<void> _prevTrack(
      _PlayerPrevEvent event, Emitter<PlayerState> emit) async {
    _playerRepository.prev();
    add(const PlayerEvent.changeState());
  }

  Future<void> _nextTrack(
      _PlayerNextEvent event, Emitter<PlayerState> emit) async {
    _playerRepository.next();
    add(const PlayerEvent.changeState());
  }

  Future<void> _rewind(
      _PlayerRewindEvent event, Emitter<PlayerState> emit) async {
    Duration newPosition = Duration(seconds: event.seconds);
    final trackIndex = state.trackIndex;
    Duration rewindPosition = state.trackPosition - newPosition;
    // if (rewindPosition < Duration.zero) {
    //   Duration prevTrackPosition =
    //       state.tracks[state.trackIndex - 1].duration - rewindPosition;
    //   _playerRepository.rewind(
    //       newPosition: prevTrackPosition, trackIndex: trackIndex - 1);
    //       add(const PlayerEvent.changeState());
    // } else {
    _playerRepository.rewind(
        newPosition: rewindPosition, trackIndex: trackIndex);
    // }
  }

  Future<void> _push(_PlayerPushEvent event, Emitter<PlayerState> emit) async {
    final trackIndex = state.trackIndex;
    _playerRepository.push(seconds: event.seconds, trackIndex: trackIndex);
  }

  Future<void> _changeTrackProgressBar(_PlayerChangeTrackProgressBarEvent event,
      Emitter<PlayerState> emit) async {
    await _playerRepository.changeTrackProgressBar(duration: event.newPosition);
  }

  Future<void> _changeAlbumProgressBar(_PlayerChangeAlbumProgressBarEvent event,
      Emitter<PlayerState> emit) async {
    await _playerRepository.changeAlbumProgressBar(duration: event.newPosition);
  }

  Future<void> _changeTrackPositionInSeconds(
      _PlayerChangePositionInSecondsEvent event,
      Emitter<PlayerState> emit) async {
    if (event.position != null) {
      emit(state.copyWith(trackPosition: event.position!));
    }
    add(const PlayerEvent.changeState());
  }

  Future<void> _changeState(
      _PlayerChangeStateEvent event, Emitter<PlayerState> emit) async {
    Duration trackDuration = state.album.tracks[state.trackIndex].duration;
    int currentIndex = _playerRepository.currentIndex;
    if (currentIndex != state.trackIndex) {
      final artwork = await _playerRepository.getArtwork(index: currentIndex);
      emit(state.copyWith(artwork: artwork));
    }
    Duration trackPosition = _playerRepository.trackPosition;
    Duration position = state.mapAlbumDuration[currentIndex] ?? Duration.zero;
    final albumPosition = position + trackPosition;
    emit(state.copyWith(
      trackDuration: trackDuration,
      trackIndex: currentIndex,
      trackPosition: trackPosition,
      album: state.album.copyWith(albumPosition: albumPosition),
    ));
  }

  @override
  PlayerState fromJson(Map<String, dynamic> json) {
    add(const PlayerEvent.initial());
    return PlayerState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(PlayerState state) {
    return state.toJson();
  }
}
