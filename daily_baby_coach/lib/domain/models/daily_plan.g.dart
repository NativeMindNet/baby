// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyPlanAdapter extends TypeAdapter<DailyPlan> {
  @override
  final int typeId = 4;

  @override
  DailyPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyPlan(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      taskIds: (fields[2] as List).cast<String>(),
      isToughDayMode: fields[3] as bool,
      generatedAt: fields[4] as DateTime,
      completed: (fields[5] as Map).cast<String, bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, DailyPlan obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.taskIds)
      ..writeByte(3)
      ..write(obj.isToughDayMode)
      ..writeByte(4)
      ..write(obj.generatedAt)
      ..writeByte(5)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
