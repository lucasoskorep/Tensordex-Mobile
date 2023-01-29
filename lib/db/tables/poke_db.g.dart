// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poke_db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PokeAdapter extends TypeAdapter<Poke> {
  @override
  final int typeId = 1;

  @override
  Poke read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Poke(
      id: fields[0] as String,
      name: fields[1] as String,
      seen: fields[2] as bool,
      images: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Poke obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.seen)
      ..writeByte(3)
      ..write(obj.images);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
