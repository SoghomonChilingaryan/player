import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:player/src/common/formatters/format_duration.dart';
import 'package:player/src/features/album/domain/entities/album.dart';
import 'package:player/src/features/mp3_player/domain/entities/my_playback_event.dart';
import 'package:player/src/features/mp3_player/domain/repository/player_repository.dart';
import 'package:player/src/features/tracks/domain/entities/track.dart';

part 'player_event.dart';
part 'player_state.dart';

part 'player_bloc.freezed.dart';
part 'player_bloc.g.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> with HydratedMixin {
  final IAudioPlayerRepository _playerRepository;
  PlayerBloc({required IAudioPlayerRepository playerRepository})
      : _playerRepository = playerRepository,
        super(const PlayerState()) {
    _playerRepository.playbackEventSubject.listen((event) async {
      add(PlayerEvent.addPlaybackEvent(playbackEvent: event));
    }, cancelOnError: false);

    on<PlayerEvent>((event, emit) async {
      await event.map<Future<void>>(
          initial: (event) => _initial(event, emit),
          addTrack: (event) => _addTrack(event, emit),
          keepPlayingAlbum: (event) => _keepPlayingAlbum(event, emit),
          play: (event) => _playEvent(event, emit),
          pause: (event) => _pauseEvent(event, emit),
          prev: (event) => _prevTrack(event, emit),
          next: (event) => _nextTrack(event, emit),
          rewind: (event) => _rewind(event, emit),
          push: (event) => _push(event, emit),
          addPlaybackEvent: (event) => _addPlaybackEvent(event, emit),
          changeTrackProgressBar: (event) =>
              _changeTrackProgressBar(event, emit),
          changeAlbumProgressBar: (event) =>
              _changeAlbumProgressBar(event, emit),
          changeSpeed: (event) => _changeSpeed(event, emit));
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
        trackPosition: state.album.trackPosition,
        trackIndex: state.album.trackIndex,
        speed: state.trackSpeed,
      );
    }
  }

  Future<void> _addTrack(
      _PlayerAddTrackEvent event, Emitter<PlayerState> emit) async {
    await _playerRepository.addMusicDirectory(
      tracks: event.album.tracks,
      trackIndex: event.track.index,
      trackPosition: event.track.position,
      speed: state.trackSpeed,
    );
    emit(state.copyWith(album: event.album));
    add(const PlayerEvent.play());
  }

  Future<void> _keepPlayingAlbum(
      _PlayerKeepPlayingAlbumEvent event, Emitter<PlayerState> emit) async {
    _playerRepository.addMusicDirectory(
      tracks: event.album.tracks,
      trackIndex: event.album.trackIndex,
      trackPosition: event.album.trackPosition,
      speed: state.trackSpeed,
    );
    emit(state.copyWith(
      album: event.album,
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
    _changeState(emit);
  }

  Future<void> _nextTrack(
      _PlayerNextEvent event, Emitter<PlayerState> emit) async {
    _playerRepository.next();
    _changeState(emit);
  }

  Future<void> _rewind(
      _PlayerRewindEvent event, Emitter<PlayerState> emit) async {
    Duration newPosition = Duration(seconds: event.seconds);
    Duration rewindPosition = state.album.trackPosition - newPosition;
    _playerRepository.rewind(newPosition: rewindPosition);
  }

  Future<void> _push(_PlayerPushEvent event, Emitter<PlayerState> emit) async {
    Duration newPosition = Duration(seconds: event.seconds);
    Duration rewindPosition = state.album.trackPosition + newPosition;
    _playerRepository.forward(newPosition: rewindPosition);
  }

  Future<void> _changeTrackProgressBar(_PlayerChangeTrackProgressBarEvent event,
      Emitter<PlayerState> emit) async {
    await _playerRepository.changeTrackProgressBar(duration: event.newPosition);
  }

  Future<void> _changeAlbumProgressBar(_PlayerChangeAlbumProgressBarEvent event,
      Emitter<PlayerState> emit) async {
    await _playerRepository.changeAlbumProgressBar(
        nowAlbumDuration: event.newPosition,
        mapAlbumDuration: state.album.mapAlbumDuration);
  }

  Future<void> _changeSpeed(
      _PlayerSpeedEvent event, Emitter<PlayerState> emit) async {
    _playerRepository.setSpeed(speed: event.speed);
    emit(state.copyWith(trackSpeed: event.speed));
  }

  Future<void> _addPlaybackEvent(
      _PlayerAddPlaybackEventEvent event, Emitter<PlayerState> emit) async {
    final currentStatus = state.status;
    final currentTrackPositionInSeconds = state.album.trackPosition.inSeconds;
    final newPositionInSeconds = event.playbackEvent.trackPosition.inSeconds;

    if (currentStatus != PlayerStatus.initial &&
        newPositionInSeconds != currentTrackPositionInSeconds) {
      emit(state.copyWith(
          album: state.album
              .copyWith(trackPosition: event.playbackEvent.trackPosition)));
      _changeState(emit);
    }
    if (event.playbackEvent.playing) {
      emit(state.copyWith(status: PlayerStatus.playing));
    } else {
      emit(state.copyWith(status: PlayerStatus.paused));
    }
  }

  Future<void> _changeState(Emitter<PlayerState> emit) async {
    int currentIndex = _playerRepository.currentIndex;
    final track = state.album.tracks[currentIndex];
    Duration trackDuration = track.duration;
    if (currentIndex != state.album.trackIndex) {
      emit(state.copyWith(album: state.album.copyWith(trackId: track.trackId)));
      _playerRepository.changeMediaItem(track: track);
    }
    Duration trackPosition = _playerRepository.trackPosition;
    Duration position = state.album.mapAlbumDuration[currentIndex]!;
    final albumPosition = position + trackPosition;
    final albumTimeLeft =
        '-${formatDuration(state.album.albumDuration - albumPosition)}';
    final trackTimeLeft =
        '-${formatDuration(state.album.trackDuration - trackPosition)}';
    emit(state.copyWith(
      trackName: track.name ?? '',
      album: state.album.copyWith(
        albumPosition: albumPosition,
        trackIndex: currentIndex,
        trackPosition: trackPosition,
        trackDuration: trackDuration,
        albumTimeLeft: albumTimeLeft,
        trackTimeLeft: trackTimeLeft,
      ),
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
