import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../../domain/models/skill_category.dart';
import '../../domain/models/task.dart';
import '../../domain/repositories/task_repository.dart';

/// Implementation of TaskRepository using Hive + JSON assets
class TaskRepositoryImpl implements TaskRepository {
  final Box _tasksBox = Hive.box('tasks');
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  int get taskCount => _tasksBox.length;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    // Check if tasks already loaded from previous session
    if (_tasksBox.isNotEmpty) {
      _initialized = true;
      return;
    }

    // Load tasks from JSON asset
    try {
      final jsonString = await rootBundle.loadString('assets/tasks/tasks_en.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // Parse and store each task
      for (var json in jsonList) {
        final task = Task.fromJson(json as Map<String, dynamic>);
        await _tasksBox.put(task.id, task);
      }

      _initialized = true;
    } catch (e) {
      // If JSON not found or invalid, create empty box
      // This allows app to run even without task data
      _initialized = true;
      rethrow; // But propagate error for logging
    }
  }

  @override
  List<Task> getAllTasks() {
    return _tasksBox.values.cast<Task>().toList();
  }

  @override
  List<Task> getTasksForAge(int ageDays) {
    return _tasksBox.values
        .cast<Task>()
        .where((task) => task.isAppropriateForAge(ageDays))
        .toList();
  }

  @override
  List<Task> getTasksForSkill(SkillCategory skill, int ageDays) {
    return _tasksBox.values
        .cast<Task>()
        .where((task) =>
            task.category == skill && task.isAppropriateForAge(ageDays))
        .toList();
  }

  @override
  Task? getTaskById(String taskId) {
    return _tasksBox.get(taskId) as Task?;
  }

  @override
  Task? getFallbackTask(String taskId) {
    final task = getTaskById(taskId);
    if (task?.fallbackTaskId == null) return null;
    return getTaskById(task!.fallbackTaskId!);
  }

  @override
  List<Task> getTasksByDifficulty(int difficulty, int ageDays) {
    return _tasksBox.values
        .cast<Task>()
        .where((task) =>
            task.difficulty == difficulty && task.isAppropriateForAge(ageDays))
        .toList();
  }

  /// Get tasks excluding recently used ones
  List<Task> getTasksExcluding(
    List<String> excludeIds,
    SkillCategory skill,
    int ageDays,
  ) {
    return getTasksForSkill(skill, ageDays)
        .where((task) => !excludeIds.contains(task.id))
        .toList();
  }

  /// Get tasks closest to target difficulty
  List<Task> getTasksByTargetDifficulty(
    int targetDifficulty,
    SkillCategory skill,
    int ageDays,
  ) {
    final tasks = getTasksForSkill(skill, ageDays);

    // Sort by distance from target difficulty
    tasks.sort((a, b) {
      final diffA = (a.difficulty - targetDifficulty).abs();
      final diffB = (b.difficulty - targetDifficulty).abs();
      return diffA.compareTo(diffB);
    });

    return tasks;
  }
}
