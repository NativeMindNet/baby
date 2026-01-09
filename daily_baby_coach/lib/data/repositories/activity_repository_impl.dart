import 'package:hive/hive.dart';
import '../../domain/models/activity_result.dart';
import '../../domain/models/skill_category.dart';
import '../../domain/repositories/activity_repository.dart';
import '../../domain/repositories/task_repository.dart';

/// Hive implementation of ActivityRepository
class ActivityRepositoryImpl implements ActivityRepository {
  final Box _resultsBox = Hive.box('activityResults');
  final TaskRepository _taskRepository;

  ActivityRepositoryImpl(this._taskRepository);

  @override
  Future<void> recordResult(ActivityResult result) async {
    await _resultsBox.put(result.id, result);
  }

  @override
  List<ActivityResult> getResultsForLast(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return _resultsBox.values
        .cast<ActivityResult>()
        .where((result) => result.completedAt.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt)); // Most recent first
  }

  @override
  List<ActivityResult> getResultsForSkill(SkillCategory skill) {
    return _resultsBox.values
        .cast<ActivityResult>()
        .where((result) {
          final task = _taskRepository.getTaskById(result.taskId);
          return task?.category == skill;
        })
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  @override
  List<ActivityResult> getResultsForTask(String taskId) {
    return _resultsBox.values
        .cast<ActivityResult>()
        .where((result) => result.taskId == taskId)
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  @override
  ActivityResult? getMostRecentResultForTask(String taskId) {
    final results = getResultsForTask(taskId);
    return results.isEmpty ? null : results.first;
  }

  @override
  int get totalActivitiesCount => _resultsBox.length;

  @override
  Future<void> cleanupOldResults() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
    final keysToDelete = <dynamic>[];

    for (var key in _resultsBox.keys) {
      final result = _resultsBox.get(key) as ActivityResult?;
      if (result != null && result.completedAt.isBefore(cutoffDate)) {
        keysToDelete.add(key);
      }
    }

    for (var key in keysToDelete) {
      await _resultsBox.delete(key);
    }
  }
}
