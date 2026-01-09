import '../models/daily_plan.dart';

/// Repository interface for daily plan data
abstract class DailyPlanRepository {
  /// Get plan for a specific date
  Future<DailyPlan?> getPlanForDate(DateTime date);

  /// Save or update a daily plan
  Future<void> savePlan(DailyPlan plan);

  /// Get the most recent plan
  Future<DailyPlan?> getMostRecentPlan();

  /// Get plans from the last N days
  Future<List<DailyPlan>> getPlansForLastDays(int days);

  /// Mark a task as completed in today's plan
  Future<void> markTaskCompleted(String planId, String taskId);

  /// Delete a plan (for testing)
  Future<void> deletePlan(String planId);

  /// Check if plan exists for today
  Future<bool> hasPlanForToday();
}
