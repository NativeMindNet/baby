import '../models/activity_result.dart';
import '../models/skill_category.dart';

/// Repository interface for activity result data
abstract class ActivityRepository {
  /// Record a completed activity with feedback
  Future<void> recordResult(ActivityResult result);

  /// Get all activity results from the last N days
  List<ActivityResult> getResultsForLast(int days);

  /// Get all results for a specific skill category
  List<ActivityResult> getResultsForSkill(SkillCategory skill);

  /// Get all results for a specific task ID
  List<ActivityResult> getResultsForTask(String taskId);

  /// Get the most recent result for a task
  ActivityResult? getMostRecentResultForTask(String taskId);

  /// Get total count of completed activities
  int get totalActivitiesCount;

  /// Clean up old results (older than 90 days)
  Future<void> cleanupOldResults();
}
