// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_score.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SkillScoreAdapter extends TypeAdapter<SkillScore> {
  @override
  final int typeId = 3;

  @override
  SkillScore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SkillScore(
      skill: fields[0] as SkillCategory,
      score: fields[1] as int,
      recentResults: (fields[2] as List).cast<int>(),
      streakEasy: fields[3] as int,
      streakHard: fields[4] as int,
      lastUsed: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SkillScore obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.skill)
      ..writeByte(1)
      ..write(obj.score)
      ..writeByte(2)
      ..write(obj.recentResults)
      ..writeByte(3)
      ..write(obj.streakEasy)
      ..writeByte(4)
      ..write(obj.streakHard)
      ..writeByte(5)
      ..write(obj.lastUsed)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
