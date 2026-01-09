// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'baby_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BabyProfileAdapter extends TypeAdapter<BabyProfile> {
  @override
  final int typeId = 1;

  @override
  BabyProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BabyProfile(
      id: fields[0] as String,
      birthDate: fields[1] as DateTime,
      capabilities: (fields[2] as Map).cast<String, bool>(),
      lastCapabilityUpdate: fields[3] as DateTime,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BabyProfile obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.birthDate)
      ..writeByte(2)
      ..write(obj.capabilities)
      ..writeByte(3)
      ..write(obj.lastCapabilityUpdate)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BabyProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
