// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_draft.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoDraftAdapter extends TypeAdapter<TodoDraft> {
  @override
  final int typeId = 3;

  @override
  TodoDraft read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoDraft(
      title: fields[0] as String,
      imagePath: fields[1] as String?,
      tags: (fields[2] as List).cast<Tag>(),
      dueDate: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TodoDraft obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.tags)
      ..writeByte(3)
      ..write(obj.dueDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoDraftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
