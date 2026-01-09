import 'package:hive/hive.dart';
import 'skill_category.dart';

part 'task.g.dart';

/// A single developmental activity for a baby
@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id; // e.g., "attn_5m_01"

  @HiveField(1)
  final int minAgeDays; // Minimum age in days (e.g., 150 for 5 months)

  @HiveField(2)
  final int maxAgeDays; // Maximum age in days (e.g., 180 for 6 months)

  @HiveField(3)
  final int durationMinutes; // Expected duration (e.g., 5)

  @HiveField(4)
  final SkillCategory category; // Which skill this develops

  @HiveField(5)
  final int difficulty; // 1-5, where 1 is easiest

  @HiveField(6)
  final String titleKey; // i18n key for title (e.g., "attn_5m_01_title")

  @HiveField(7)
  final List<String> stepKeys; // i18n keys for steps

  @HiveField(8)
  final String? stopIfKey; // Optional i18n key for "stop if" guidance

  @HiveField(9)
  final String? fallbackTaskId; // ID of easier alternative task

  const Task({
    required this.id,
    required this.minAgeDays,
    required this.maxAgeDays,
    required this.durationMinutes,
    required this.category,
    required this.difficulty,
    required this.titleKey,
    required this.stepKeys,
    this.stopIfKey,
    this.fallbackTaskId,
  });

  /// Create Task from JSON (for loading from assets)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      minAgeDays: json['minAgeDays'] as int,
      maxAgeDays: json['maxAgeDays'] as int,
      durationMinutes: json['duration'] as int,
      category: SkillCategory.values.byName(json['category'] as String),
      difficulty: json['difficulty'] as int,
      titleKey: json['titleKey'] as String,
      stepKeys: (json['stepsKeys'] as List<dynamic>).cast<String>(),
      stopIfKey: json['stopIfKey'] as String?,
      fallbackTaskId: json['fallback'] as String?,
    );
  }

  /// Convert Task to JSON (for debugging/export)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'minAgeDays': minAgeDays,
      'maxAgeDays': maxAgeDays,
      'duration': durationMinutes,
      'category': category.name,
      'difficulty': difficulty,
      'titleKey': titleKey,
      'stepsKeys': stepKeys,
      'stopIfKey': stopIfKey,
      'fallback': fallbackTaskId,
    };
  }

  /// Check if task is appropriate for given age
  bool isAppropriateForAge(int ageDays) {
    return ageDays >= minAgeDays && ageDays <= maxAgeDays;
  }

  /// Get fallback task (easier alternative)
  Task? getFallback(Map<String, Task> allTasks) {
    if (fallbackTaskId == null) return null;
    return allTasks[fallbackTaskId];
  }

  @override
  String toString() {
    return 'Task(id: $id, category: ${category.name}, difficulty: $difficulty)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
