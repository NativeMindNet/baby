// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SkillCategoryAdapter extends TypeAdapter<SkillCategory> {
  @override
  final int typeId = 10;

  @override
  SkillCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SkillCategory.regulation;
      case 1:
        return SkillCategory.attention;
      case 2:
        return SkillCategory.motor;
      case 3:
        return SkillCategory.causeEffect;
      case 4:
        return SkillCategory.communication;
      case 5:
        return SkillCategory.independence;
      default:
        return SkillCategory.regulation;
    }
  }

  @override
  void write(BinaryWriter writer, SkillCategory obj) {
    switch (obj) {
      case SkillCategory.regulation:
        writer.writeByte(0);
        break;
      case SkillCategory.attention:
        writer.writeByte(1);
        break;
      case SkillCategory.motor:
        writer.writeByte(2);
        break;
      case SkillCategory.causeEffect:
        writer.writeByte(3);
        break;
      case SkillCategory.communication:
        writer.writeByte(4);
        break;
      case SkillCategory.independence:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
