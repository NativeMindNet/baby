import '../models/skill_category.dart';
import '../models/task.dart';

/// Repository interface for task data
abstract class TaskRepository {
  /// Initialize repository (load tasks from JSON)
  Future<void> initialize();

  /// Get all tasks
  List<Task> getAllTasks();

  /// Get tasks appropriate for a specific age
  List<Task> getTasksForAge(int ageDays);

  /// Get tasks for a specific skill and age
  List<Task> getTasksForSkill(SkillCategory skill, int ageDays);

  /// Get a task by its ID
  Task? getTaskById(String taskId);

  /// Get the fallback (easier) task for a given task
  Task? getFallbackTask(String taskId);

  /// Get tasks by difficulty level
  List<Task> getTasksByDifficulty(int difficulty, int ageDays);

  /// Check if tasks are loaded
  bool get isInitialized;

  /// Get count of loaded tasks
  int get taskCount;
}
