import 'package:hive/hive.dart';
import '../models/activity_result.dart';
import '../models/feedback_score.dart';
import '../models/skill_category.dart';
import '../models/skill_score.dart';
import '../repositories/task_repository.dart';

/// Service for managing skill scores and adaptive difficulty
class SkillScoreService {
  final Box _scoresBox = Hive.box('skillScores');
  final TaskRepository _taskRepository;

  SkillScoreService(this._taskRepository);

  /// Get current score for a skill (creates initial if not exists)
  SkillScore getScore(SkillCategory skill) {
    final key = skill.name;
    var score = _scoresBox.get(key) as SkillScore?;

    if (score == null) {
      score = SkillScore.initial(skill);
      _scoresBox.put(key, score);
    }

    return score;
  }

  /// Get all skill scores (all 6 categories)
  Map<SkillCategory, SkillScore> getAllScores() {
    return {
      for (var skill in SkillCategory.values) skill: getScore(skill),
    };
  }

  /// Update skill score after completing an activity
  Future<void> updateScoreAfterActivity(ActivityResult result) async {
    // Find the task to get its skill category
    final task = _taskRepository.getTaskById(result.taskId);
    if (task == null) return;

    final skill = task.category;
    final currentScore = getScore(skill);

    // Convert feedback to numeric value
    final feedbackValue = result.feedback.value;

    // Update recent results (keep last 7)
    final newRecentResults = List<int>.from(currentScore.recentResults);
    newRecentResults.add(feedbackValue);
    if (newRecentResults.length > 7) {
      newRecentResults.removeAt(0); // Remove oldest
    }

    // Calculate new score (sum of recent results)
    final newScore = newRecentResults.fold<int>(0, (sum, val) => sum + val);

    // Update streaks
    int newStreakEasy = currentScore.streakEasy;
    int newStreakHard = currentScore.streakHard;

    if (result.feedback == FeedbackScore.easy) {
      newStreakEasy += 1;
      newStreakHard = 0;
    } else if (result.feedback == FeedbackScore.hard ||
        result.feedback == FeedbackScore.didNotWork) {
      newStreakHard += 1;
      newStreakEasy = 0;
    } else {
      // Normal feedback - reset both streaks
      newStreakEasy = 0;
      newStreakHard = 0;
    }

    // Create updated SkillScore
    final updatedScore = currentScore.copyWith(
      score: newScore,
      recentResults: newRecentResults,
      streakEasy: newStreakEasy,
      streakHard: newStreakHard,
      lastUsed: result.completedAt,
      updatedAt: DateTime.now(),
    );

    // Save to Hive
    await _scoresBox.put(skill.name, updatedScore);
  }

  /// Get recommended difficulty adjustment for a skill
  /// Returns: -1 (easier), 0 (same), +1 (harder)
  int getRecommendedDifficultyAdjustment(SkillCategory skill) {
    final score = getScore(skill);

    if (score.needsSupport) {
      return -1; // Make it easier
    } else if (score.needsChallenge) {
      return 1; // Make it harder
    }

    return 0; // Keep same difficulty
  }

  /// Get skills that need practice (stale or struggling)
  List<SkillCategory> getSkillsNeedingAttention() {
    final allScores = getAllScores();
    final skillsNeeding = <SkillCategory>[];

    for (var entry in allScores.entries) {
      final score = entry.value;
      if (score.needsSupport || score.isStale) {
        skillsNeeding.add(entry.key);
      }
    }

    // Sort by priority: struggling first, then stale, then by last used
    skillsNeeding.sort((a, b) {
      final scoreA = allScores[a]!;
      final scoreB = allScores[b]!;

      // Struggling skills first
      if (scoreA.needsSupport && !scoreB.needsSupport) return -1;
      if (!scoreA.needsSupport && scoreB.needsSupport) return 1;

      // Then by staleness
      if (scoreA.isStale && !scoreB.isStale) return -1;
      if (!scoreA.isStale && scoreB.isStale) return 1;

      // Finally by last used (older first)
      if (scoreA.lastUsed == null && scoreB.lastUsed != null) return -1;
      if (scoreA.lastUsed != null && scoreB.lastUsed == null) return 1;
      if (scoreA.lastUsed != null && scoreB.lastUsed != null) {
        return scoreA.lastUsed!.compareTo(scoreB.lastUsed!);
      }

      return 0;
    });

    return skillsNeeding;
  }

  /// Reset all scores (for testing or fresh start)
  Future<void> resetAllScores() async {
    await _scoresBox.clear();
  }

  /// Reset a specific skill score
  Future<void> resetScore(SkillCategory skill) async {
    await _scoresBox.delete(skill.name);
  }
}
