// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Album _$$_AlbumFromJson(Map<String, dynamic> json) => _$_Album(
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => Track.fromJson(e as Map<String, dynamic>))
          .toList(),
      artworkAlbum:
          (json['artworkAlbum'] as List<dynamic>).map((e) => e as int).toList(),
      albumDuration: Duration(microseconds: json['albumDuration'] as int),
      albumPosition: Duration(microseconds: json['albumPosition'] as int),
      id: json['id'] as int,
      name: json['name'] as String,
      artist: json['artist'] as String,
    );

Map<String, dynamic> _$$_AlbumToJson(_$_Album instance) => <String, dynamic>{
      'tracks': instance.tracks,
      'artworkAlbum': instance.artworkAlbum,
      'albumDuration': instance.albumDuration.inMicroseconds,
      'albumPosition': instance.albumPosition.inMicroseconds,
      'id': instance.id,
      'name': instance.name,
      'artist': instance.artist,
    };
