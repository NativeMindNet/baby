import 'package:uuid/uuid.dart';
import '../models/daily_plan.dart';
import '../models/skill_category.dart';
import '../models/task.dart';
import '../repositories/daily_plan_repository.dart';
import '../repositories/task_repository.dart';
import 'adaptive_engine.dart';

/// Service for managing daily plans
class DailyPlanService {
  final DailyPlanRepository _planRepository;
  final TaskRepository _taskRepository;
  final AdaptiveEngine _adaptiveEngine;
  final Uuid _uuid = const Uuid();

  DailyPlanService(
    this._planRepository,
    this._taskRepository,
    this._adaptiveEngine,
  );

  /// Get or generate today's plan
  Future<DailyPlan> getTodaysPlan({bool isToughDayMode = false}) async {
    final today = DateTime.now();
    final existingPlan = await _planRepository.getPlanForDate(today);

    if (existingPlan != null) {
      return existingPlan;
    }

    // Generate new plan
    return await generatePlanForDate(today, isToughDayMode: isToughDayMode);
  }

  /// Generate a new plan for a specific date
  Future<DailyPlan> generatePlanForDate(
    DateTime date, {
    bool isToughDayMode = false,
  }) async {
    // Get recent plans to avoid repetition
    final recentPlans = await _planRepository.getPlansForLastDays(3);

    // Extract recent skills and task IDs
    final recentSkills = <SkillCategory>{};
    final recentTaskIds = <String>{};

    for (var plan in recentPlans) {
      for (var taskId in plan.taskIds) {
        recentTaskIds.add(taskId);

        final task = _taskRepository.getTaskById(taskId);
        if (task != null) {
          recentSkills.add(task.category);
        }
      }
    }

    // Use adaptive engine to select tasks
    final taskIds = await _adaptiveEngine.selectTasksForDailyPlan(
      isToughDayMode: isToughDayMode,
      recentSkills: recentSkills.toList(),
      recentTaskIds: recentTaskIds.toList(),
    );

    // Create and save plan
    final plan = DailyPlan.forDate(
      id: _uuid.v4(),
      date: date,
      taskIds: taskIds,
      isToughDayMode: isToughDayMode,
    );

    await _planRepository.savePlan(plan);

    return plan;
  }

  /// Regenerate today's plan (e.g., after toggling tough day mode)
  Future<DailyPlan> regenerateTodaysPlan({bool isToughDayMode = false}) async {
    final today = DateTime.now();
    final existingPlan = await _planRepository.getPlanForDate(today);

    // Delete existing plan if it exists
    if (existingPlan != null) {
      await _planRepository.deletePlan(existingPlan.id);
    }

    return await generatePlanForDate(today, isToughDayMode: isToughDayMode);
  }

  /// Get plan for a specific date
  Future<DailyPlan?> getPlanForDate(DateTime date) async {
    return await _planRepository.getPlanForDate(date);
  }

  /// Mark a task as completed
  Future<void> markTaskCompleted(String planId, String taskId) async {
    await _planRepository.markTaskCompleted(planId, taskId);
  }

  /// Get tasks for a plan (converts task IDs to Task objects)
  List<Task> getTasksForPlan(DailyPlan plan) {
    final tasks = <Task>[];

    for (var taskId in plan.taskIds) {
      final task = _taskRepository.getTaskById(taskId);
      if (task != null) {
        tasks.add(task);
      }
    }

    return tasks;
  }

  /// Check if today has a plan
  Future<bool> hasPlanForToday() async {
    return await _planRepository.hasPlanForToday();
  }

  /// Get plans from the last N days (for history view)
  Future<List<DailyPlan>> getRecentPlans(int days) async {
    return await _planRepository.getPlansForLastDays(days);
  }

  /// Calculate completion rate for last N days
  Future<double> getCompletionRateForLastDays(int days) async {
    final plans = await _planRepository.getPlansForLastDays(days);

    if (plans.isEmpty) return 0.0;

    int totalTasks = 0;
    int completedTasks = 0;

    for (var plan in plans) {
      totalTasks += plan.taskCount;
      completedTasks += plan.completedCount;
    }

    if (totalTasks == 0) return 0.0;

    return completedTasks / totalTasks;
  }

  /// Get current streak (consecutive days with at least 1 completed task)
  Future<int> getCurrentStreak() async {
    final plans = await _planRepository.getPlansForLastDays(30);

    if (plans.isEmpty) return 0;

    // Sort by date (most recent first)
    plans.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    final today = DateTime.now();
    var checkDate = DateTime(today.year, today.month, today.day);

    for (var plan in plans) {
      final planDate = DateTime(plan.date.year, plan.date.month, plan.date.day);

      if (planDate.isAtSameMomentAs(checkDate)) {
        if (plan.completedCount > 0) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break; // Streak broken
        }
      } else if (planDate.isBefore(checkDate)) {
        break; // Gap in plans
      }
    }

    return streak;
  }
}
