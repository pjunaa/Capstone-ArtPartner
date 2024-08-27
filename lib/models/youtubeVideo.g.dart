// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'youtubeVideo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class YouTubeVideoAdapter extends TypeAdapter<YouTubeVideo> {
  @override
  final int typeId = 0;

  @override
  YouTubeVideo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return YouTubeVideo(
      title: fields[0] as String,
      thumbnailUrl: fields[1] as String,
      videoId: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, YouTubeVideo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.thumbnailUrl)
      ..writeByte(2)
      ..write(obj.videoId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YouTubeVideoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
