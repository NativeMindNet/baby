import 'package:hive/hive.dart';

part 'daily_plan.g.dart';

/// A daily set of recommended activities
@HiveType(typeId: 4)
class DailyPlan {
  @HiveField(0)
  final String id; // UUID

  @HiveField(1)
  final DateTime date; // Date this plan is for (midnight local time)

  @HiveField(2)
  final List<String> taskIds; // 2-3 task IDs (or 1 if tough day mode)

  @HiveField(3)
  final bool isToughDayMode; // Simplified plan?

  @HiveField(4)
  final DateTime generatedAt; // When plan was created

  @HiveField(5)
  final Map<String, bool> completed; // taskId -> completion status

  const DailyPlan({
    required this.id,
    required this.date,
    required this.taskIds,
    required this.isToughDayMode,
    required this.generatedAt,
    required this.completed,
  });

  /// Number of tasks in this plan
  int get taskCount => taskIds.length;

  /// Number of completed tasks
  int get completedCount => completed.values.where((c) => c).length;

  /// Whether all tasks are completed
  bool get isComplete => completedCount == taskCount;

  /// Completion progress (0.0 to 1.0)
  double get progress => taskCount == 0 ? 0.0 : completedCount / taskCount;

  /// Check if a specific task is completed
  bool isTaskCompleted(String taskId) {
    return completed[taskId] ?? false;
  }

  /// Mark a task as completed
  DailyPlan markTaskCompleted(String taskId) {
    final newCompleted = Map<String, bool>.from(completed);
    newCompleted[taskId] = true;
    return copyWith(completed: newCompleted);
  }

  /// Create a copy with updated fields
  DailyPlan copyWith({
    String? id,
    DateTime? date,
    List<String>? taskIds,
    bool? isToughDayMode,
    DateTime? generatedAt,
    Map<String, bool>? completed,
  }) {
    return DailyPlan(
      id: id ?? this.id,
      date: date ?? this.date,
      taskIds: taskIds ?? this.taskIds,
      isToughDayMode: isToughDayMode ?? this.isToughDayMode,
      generatedAt: generatedAt ?? this.generatedAt,
      completed: completed ?? this.completed,
    );
  }

  /// Get date string for storage key (YYYY-MM-DD)
  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Create a plan for a specific date
  factory DailyPlan.forDate({
    required String id,
    required DateTime date,
    required List<String> taskIds,
    bool isToughDayMode = false,
  }) {
    // Normalize date to midnight
    final normalizedDate = DateTime(date.year, date.month, date.day);

    return DailyPlan(
      id: id,
      date: normalizedDate,
      taskIds: taskIds,
      isToughDayMode: isToughDayMode,
      generatedAt: DateTime.now(),
      completed: {for (var taskId in taskIds) taskId: false},
    );
  }

  @override
  String toString() {
    return 'DailyPlan(date: $dateKey, tasks: $taskCount, completed: $completedCount, toughDay: $isToughDayMode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyPlan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
