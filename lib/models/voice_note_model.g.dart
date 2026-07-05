// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VoiceNoteModelAdapter extends TypeAdapter<VoiceNoteModel> {
  @override
  final int typeId = 2;

  @override
  VoiceNoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VoiceNoteModel(
      id: fields[0] as String,
      title: fields[1] as String,
      filePath: fields[2] as String,
      createdAt: fields[3] as DateTime,
      durationSeconds: fields[4] as int,
      tags: (fields[5] as List).cast<String>(),
      isFavorite: fields[6] as bool,
      transcript: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VoiceNoteModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.durationSeconds)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.isFavorite)
      ..writeByte(7)
      ..write(obj.transcript);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceNoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
