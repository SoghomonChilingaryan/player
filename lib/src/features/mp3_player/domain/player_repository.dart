import 'package:player/src/features/track_list/domain/entities/track.dart';

abstract class IAudioPlayerRepository {
  Stream<Duration> get positionStream;
  Stream<Duration?> get totalStream;
  Stream<bool> get playingStream;

  int? get currentIndex;
  Duration get trackDuration;
  Duration get trackPosition;
  Map<int, Duration> get getMapAlbumDuration;

  Duration get albumDuration;
  Stream<int?> get trackIndexStream;
  Future<List<int>> addMusicDirectory(
      {required List<Track> tracks, required Track track});

  Future<void> next();

  Future<void> pause();

  Future<void> play();

  Future<void> prev();
  Future<void> rewind({required int seconds});

  Future<void> push({required int seconds});
  Future<void> changeTrackProgressBar({required Duration duration});
  Future<void> changeAlbumProgressBar({required Duration duration});
}