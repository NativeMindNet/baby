import 'package:hive/hive.dart';

part 'feedback_score.g.dart';

/// Parent feedback after completing an activity
@HiveType(typeId: 11)
enum FeedbackScore {
  @HiveField(0)
  easy(1),         // 👍 Too easy

  @HiveField(1)
  normal(0),       // 😐 Just right

  @HiveField(2)
  hard(-1),        // 😣 Challenging

  @HiveField(3)
  didNotWork(-2);  // ⛔ Failed/baby upset

  final int value;
  const FeedbackScore(this.value);

  /// Display name for UI
  String get displayName {
    switch (this) {
      case FeedbackScore.easy:
        return 'Easy';
      case FeedbackScore.normal:
        return 'Just right';
      case FeedbackScore.hard:
        return 'Challenging';
      case FeedbackScore.didNotWork:
        return 'Didn\'t work';
    }
  }

  /// Emoji for UI
  String get emoji {
    switch (this) {
      case FeedbackScore.easy:
        return '👍';
      case FeedbackScore.normal:
        return '😐';
      case FeedbackScore.hard:
        return '😣';
      case FeedbackScore.didNotWork:
        return '⛔';
    }
  }

  /// Whether this indicates success
  bool get isSuccess => value >= 0;

  /// Whether this indicates difficulty
  bool get isDifficult => value < 0;
}
