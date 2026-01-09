import 'dart:math';
import '../models/skill_category.dart';
import '../models/task.dart';
import '../repositories/profile_repository.dart';
import '../repositories/task_repository.dart';
import 'skill_score_service.dart';

/// Core adaptive engine for selecting skills and tasks
class AdaptiveEngine {
  final TaskRepository _taskRepository;
  final ProfileRepository _profileRepository;
  final SkillScoreService _skillScoreService;
  final Random _random = Random();

  AdaptiveEngine(
    this._taskRepository,
    this._profileRepository,
    this._skillScoreService,
  );

  /// Select 2-3 skills for today's plan (or 1 if tough day mode)
  /// Algorithm:
  /// 1. Prioritize skills needing support or stale skills
  /// 2. Ensure variety (different from yesterday if possible)
  /// 3. Random selection from remaining skills
  Future<List<SkillCategory>> selectSkillsForToday({
    required bool isToughDayMode,
    List<SkillCategory>? recentSkills,
  }) async {
    final skillsNeeding = _skillScoreService.getSkillsNeedingAttention();
    final allScores = _skillScoreService.getAllScores();

    // Available skills (excluding recently used if we have enough variety)
    final availableSkills = SkillCategory.values.toList();

    if (isToughDayMode) {
      // Tough day: pick 1 skill, prefer easier/familiar ones
      if (skillsNeeding.isNotEmpty) {
        // If struggling, pick the one that needs support most
        return [skillsNeeding.first];
      }

      // Otherwise pick a skill they're comfortable with (not stale)
      final comfortableSkills = availableSkills.where((skill) {
        final score = allScores[skill]!;
        return !score.isStale && score.comfortLevel >= 2;
      }).toList();

      if (comfortableSkills.isNotEmpty) {
        return [comfortableSkills[_random.nextInt(comfortableSkills.length)]];
      }

      // Fallback: random skill
      return [availableSkills[_random.nextInt(availableSkills.length)]];
    }

    // Normal mode: select 2-3 skills
    final selectedSkills = <SkillCategory>[];
    final targetCount = 2 + _random.nextInt(2); // 2 or 3 skills

    // Step 1: Add skills that need attention (max 2)
    for (var skill in skillsNeeding.take(2)) {
      if (!selectedSkills.contains(skill)) {
        selectedSkills.add(skill);
      }
    }

    // Step 2: Fill remaining slots avoiding recent skills if possible
    final remainingSkills = availableSkills
        .where((s) => !selectedSkills.contains(s))
        .toList();

    // Try to avoid yesterday's skills
    var candidates = remainingSkills
        .where((s) => recentSkills == null || !recentSkills.contains(s))
        .toList();

    if (candidates.isEmpty) {
      candidates = remainingSkills; // Use all if no variety possible
    }

    while (selectedSkills.length < targetCount && candidates.isNotEmpty) {
      final skill = candidates[_random.nextInt(candidates.length)];
      selectedSkills.add(skill);
      candidates.remove(skill);
    }

    return selectedSkills;
  }

  /// Select a task for a given skill and age
  /// Algorithm:
  /// 1. Get appropriate tasks for age
  /// 2. Adjust difficulty based on skill score
  /// 3. Exclude recently completed tasks (within 3 days)
  /// 4. Random selection from candidates
  Future<Task?> selectTaskForSkill(
    SkillCategory skill,
    int ageDays, {
    List<String>? recentTaskIds,
  }) async {
    // Get all tasks for this skill and age
    var candidates = _taskRepository
        .getTasksForSkill(skill, ageDays)
        .where((task) => task.isAppropriateForAge(ageDays))
        .toList();

    if (candidates.isEmpty) return null;

    // Get recommended difficulty adjustment (-1, 0, +1)
    final adjustment = _skillScoreService.getRecommendedDifficultyAdjustment(skill);

    // Calculate target difficulty based on age and score
    // Base difficulty: 1-2 for young babies, 2-3 for older
    int targetDifficulty;
    if (ageDays < 150) {
      targetDifficulty = 1 + adjustment;
    } else if (ageDays < 210) {
      targetDifficulty = 2 + adjustment;
    } else {
      targetDifficulty = 2 + adjustment;
    }
    targetDifficulty = targetDifficulty.clamp(1, 5);

    // Filter by target difficulty (±1 tolerance)
    var suitableTasks = candidates.where((task) {
      return (task.difficulty - targetDifficulty).abs() <= 1;
    }).toList();

    if (suitableTasks.isEmpty) {
      suitableTasks = candidates; // Use all if no suitable difficulty
    }

    // Exclude recently completed tasks
    if (recentTaskIds != null && recentTaskIds.isNotEmpty) {
      final notRecent = suitableTasks
          .where((task) => !recentTaskIds.contains(task.id))
          .toList();

      if (notRecent.isNotEmpty) {
        suitableTasks = notRecent;
      }
    }

    // Random selection from suitable tasks
    if (suitableTasks.isEmpty) return null;
    return suitableTasks[_random.nextInt(suitableTasks.length)];
  }

  /// Select tasks for a daily plan
  /// Returns list of task IDs
  Future<List<String>> selectTasksForDailyPlan({
    required bool isToughDayMode,
    List<SkillCategory>? recentSkills,
    List<String>? recentTaskIds,
  }) async {
    final profile = await _profileRepository.getProfile();
    if (profile == null) return [];

    final ageDays = profile.ageDays;

    // Select skills
    final skills = await selectSkillsForToday(
      isToughDayMode: isToughDayMode,
      recentSkills: recentSkills,
    );

    // Select one task per skill
    final taskIds = <String>[];
    for (var skill in skills) {
      final task = await selectTaskForSkill(
        skill,
        ageDays,
        recentTaskIds: recentTaskIds,
      );

      if (task != null) {
        taskIds.add(task.id);
      }
    }

    return taskIds;
  }

  /// Get fallback task for a given task (easier alternative)
  Task? getFallbackTask(String taskId) {
    final task = _taskRepository.getTaskById(taskId);
    if (task?.fallbackTaskId == null) return null;

    return _taskRepository.getTaskById(task!.fallbackTaskId!);
  }

  /// Check if baby profile exists
  Future<bool> hasProfile() async {
    return await _profileRepository.hasProfile();
  }
}
