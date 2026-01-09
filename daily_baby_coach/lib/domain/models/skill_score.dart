import 'package:hive/hive.dart';
import 'skill_category.dart';

part 'skill_score.g.dart';

/// Tracks progress and difficulty trends for a skill category
@HiveType(typeId: 3)
class SkillScore {
  @HiveField(0)
  final SkillCategory skill;

  @HiveField(1)
  final int score; // Sum of last 7 results (-14 to +7)

  @HiveField(2)
  final List<int> recentResults; // Last 7 feedback values

  @HiveField(3)
  final int streakEasy; // Consecutive easy completions

  @HiveField(4)
  final int streakHard; // Consecutive hard/failed

  @HiveField(5)
  final DateTime? lastUsed; // Last time this skill was practiced

  @HiveField(6)
  final DateTime updatedAt;

  const SkillScore({
    required this.skill,
    required this.score,
    required this.recentResults,
    required this.streakEasy,
    required this.streakHard,
    this.lastUsed,
    required this.updatedAt,
  });

  /// Whether this skill needs support (struggling)
  bool get needsSupport => streakHard >= 2;

  /// Whether this skill needs more challenge
  bool get needsChallenge => streakEasy >= 2;

  /// Whether this skill is stale (unused for 3+ days)
  bool get isStale {
    if (lastUsed == null) return true;
    return DateTime.now().difference(lastUsed!).inDays >= 3;
  }

  /// Comfort level (0-4) for UI indicators (●●●○)
  int get comfortLevel {
    // Map score range (-14 to +7) to 0-4
    final normalizedScore = score + 14; // Now 0 to 21
    final level = (normalizedScore / 21 * 4).round();
    return level.clamp(0, 4);
  }

  /// Status string for UI
  String get status {
    if (needsSupport) return 'Needs support';
    if (needsChallenge) return 'Ready for more';
    if (isStale) return 'Not practiced recently';
    return 'On track';
  }

  /// Create initial SkillScore for a new skill
  factory SkillScore.initial(SkillCategory skill) {
    return SkillScore(
      skill: skill,
      score: 0,
      recentResults: [],
      streakEasy: 0,
      streakHard: 0,
      lastUsed: null,
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  SkillScore copyWith({
    SkillCategory? skill,
    int? score,
    List<int>? recentResults,
    int? streakEasy,
    int? streakHard,
    DateTime? lastUsed,
    DateTime? updatedAt,
  }) {
    return SkillScore(
      skill: skill ?? this.skill,
      score: score ?? this.score,
      recentResults: recentResults ?? this.recentResults,
      streakEasy: streakEasy ?? this.streakEasy,
      streakHard: streakHard ?? this.streakHard,
      lastUsed: lastUsed ?? this.lastUsed,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SkillScore(skill: ${skill.name}, score: $score, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SkillScore && other.skill == skill;
  }

  @override
  int get hashCode => skill.hashCode;
}
