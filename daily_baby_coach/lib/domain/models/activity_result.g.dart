// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityResultAdapter extends TypeAdapter<ActivityResult> {
  @override
  final int typeId = 2;

  @override
  ActivityResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityResult(
      id: fields[0] as String,
      taskId: fields[1] as String,
      completedAt: fields[2] as DateTime,
      feedback: fields[3] as FeedbackScore,
      actualDurationMinutes: fields[4] as int,
      comment: fields[5] as String?,
      babyAgeDays: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityResult obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskId)
      ..writeByte(2)
      ..write(obj.completedAt)
      ..writeByte(3)
      ..write(obj.feedback)
      ..writeByte(4)
      ..write(obj.actualDurationMinutes)
      ..writeByte(5)
      ..write(obj.comment)
      ..writeByte(6)
      ..write(obj.babyAgeDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
