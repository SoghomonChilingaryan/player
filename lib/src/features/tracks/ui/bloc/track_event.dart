part of 'track_bloc.dart';

@freezed
class TrackEvent with _$TrackEvent {
   const factory TrackEvent.clickAlbum({
    required Album album,
    // required  int  albumId, 
    // required List<Track> treks,
  }) = _ClickAlbumTrackEvent;
}
