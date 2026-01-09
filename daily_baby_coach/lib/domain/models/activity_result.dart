import 'package:hive/hive.dart';
import 'feedback_score.dart';

part 'activity_result.g.dart';

/// Record of a completed activity with parent feedback
@HiveType(typeId: 2)
class ActivityResult {
  @HiveField(0)
  final String id; // UUID

  @HiveField(1)
  final String taskId; // Reference to Task

  @HiveField(2)
  final DateTime completedAt;

  @HiveField(3)
  final FeedbackScore feedback;

  @HiveField(4)
  final int actualDurationMinutes;

  @HiveField(5)
  final String? comment; // Optional parent note

  @HiveField(6)
  final int babyAgeDays; // Snapshot of age at completion

  const ActivityResult({
    required this.id,
    required this.taskId,
    required this.completedAt,
    required this.feedback,
    required this.actualDurationMinutes,
    this.comment,
    required this.babyAgeDays,
  });

  /// Whether the activity was successful
  bool get wasSuccessful => feedback.isSuccess;

  /// Whether the activity was too difficult
  bool get wasDifficult => feedback.isDifficult;

  /// Numeric score for this result
  int get score => feedback.value;

  @override
  String toString() {
    return 'ActivityResult(taskId: $taskId, feedback: ${feedback.name}, duration: $actualDurationMinutes min)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActivityResult && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
