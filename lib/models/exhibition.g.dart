// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exhibition.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExhibitionAdapter extends TypeAdapter<Exhibition> {
  @override
  final int typeId = 1;

  @override
  Exhibition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exhibition(
      title: fields[0] as String,
      imageUrl: fields[1] as String,
      linkUrl: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Exhibition obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.imageUrl)
      ..writeByte(2)
      ..write(obj.linkUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExhibitionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
