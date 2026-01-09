// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      minAgeDays: fields[1] as int,
      maxAgeDays: fields[2] as int,
      durationMinutes: fields[3] as int,
      category: fields[4] as SkillCategory,
      difficulty: fields[5] as int,
      titleKey: fields[6] as String,
      stepKeys: (fields[7] as List).cast<String>(),
      stopIfKey: fields[8] as String?,
      fallbackTaskId: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.minAgeDays)
      ..writeByte(2)
      ..write(obj.maxAgeDays)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.difficulty)
      ..writeByte(6)
      ..write(obj.titleKey)
      ..writeByte(7)
      ..write(obj.stepKeys)
      ..writeByte(8)
      ..write(obj.stopIfKey)
      ..writeByte(9)
      ..write(obj.fallbackTaskId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
