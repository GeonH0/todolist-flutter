// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TagAdapter extends TypeAdapter<Tag> {
  @override
  final int typeId = 2;

  @override
  Tag read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Tag.work;
      case 1:
        return Tag.personal;
      case 2:
        return Tag.study;
      case 3:
        return Tag.shopping;
      default:
        return Tag.work;
    }
  }

  @override
  void write(BinaryWriter writer, Tag obj) {
    switch (obj) {
      case Tag.work:
        writer.writeByte(0);
        break;
      case Tag.personal:
        writer.writeByte(1);
        break;
      case Tag.study:
        writer.writeByte(2);
        break;
      case Tag.shopping:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
