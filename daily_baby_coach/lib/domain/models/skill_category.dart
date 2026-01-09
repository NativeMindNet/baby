import 'package:hive/hive.dart';

part 'skill_category.g.dart';

/// Six core developmental skill categories
@HiveType(typeId: 10)
enum SkillCategory {
  @HiveField(0)
  regulation,      // 🧘 Calming, self-soothing, emotional regulation

  @HiveField(1)
  attention,       // 👀 Visual tracking, focus, engagement

  @HiveField(2)
  motor,           // 🤲 Gross and fine motor skills, body control

  @HiveField(3)
  causeEffect,     // 🔁 Understanding actions lead to results

  @HiveField(4)
  communication,   // 💬 Sounds, gestures, early language

  @HiveField(5)
  independence;    // 🧩 Self-play, problem-solving, autonomy

  /// Display name for UI
  String get displayName {
    switch (this) {
      case SkillCategory.regulation:
        return 'Calming';
      case SkillCategory.attention:
        return 'Attention';
      case SkillCategory.motor:
        return 'Movement';
      case SkillCategory.causeEffect:
        return 'Cause & Effect';
      case SkillCategory.communication:
        return 'Communication';
      case SkillCategory.independence:
        return 'Independence';
    }
  }

  /// Emoji icon for UI
  String get icon {
    switch (this) {
      case SkillCategory.regulation:
        return '🧘';
      case SkillCategory.attention:
        return '👀';
      case SkillCategory.motor:
        return '🤲';
      case SkillCategory.causeEffect:
        return '🔁';
      case SkillCategory.communication:
        return '💬';
      case SkillCategory.independence:
        return '🧩';
    }
  }

  /// Color for this skill (from AppColors)
  String get colorHex {
    switch (this) {
      case SkillCategory.regulation:
        return '#8B7EC8'; // Purple
      case SkillCategory.attention:
        return '#4A90E2'; // Blue
      case SkillCategory.motor:
        return '#E28C4A'; // Orange
      case SkillCategory.causeEffect:
        return '#50C878'; // Green
      case SkillCategory.communication:
        return '#E85D75'; // Pink
      case SkillCategory.independence:
        return '#FFB347'; // Yellow-Orange
    }
  }
}
