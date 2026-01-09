// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_score.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FeedbackScoreAdapter extends TypeAdapter<FeedbackScore> {
  @override
  final int typeId = 11;

  @override
  FeedbackScore read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FeedbackScore.easy;
      case 1:
        return FeedbackScore.normal;
      case 2:
        return FeedbackScore.hard;
      case 3:
        return FeedbackScore.didNotWork;
      default:
        return FeedbackScore.easy;
    }
  }

  @override
  void write(BinaryWriter writer, FeedbackScore obj) {
    switch (obj) {
      case FeedbackScore.easy:
        writer.writeByte(0);
        break;
      case FeedbackScore.normal:
        writer.writeByte(1);
        break;
      case FeedbackScore.hard:
        writer.writeByte(2);
        break;
      case FeedbackScore.didNotWork:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
