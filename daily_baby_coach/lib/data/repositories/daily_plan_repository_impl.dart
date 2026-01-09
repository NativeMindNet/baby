import 'package:hive/hive.dart';
import '../../domain/models/daily_plan.dart';
import '../../domain/repositories/daily_plan_repository.dart';

/// Hive implementation of DailyPlanRepository
class DailyPlanRepositoryImpl implements DailyPlanRepository {
  final Box _plansBox = Hive.box('dailyPlans');

  /// Generate storage key from date (YYYY-MM-DD)
  String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<DailyPlan?> getPlanForDate(DateTime date) async {
    final key = _dateKey(date);
    return _plansBox.get(key) as DailyPlan?;
  }

  @override
  Future<void> savePlan(DailyPlan plan) async {
    final key = plan.dateKey;
    await _plansBox.put(key, plan);
  }

  @override
  Future<DailyPlan?> getMostRecentPlan() async {
    if (_plansBox.isEmpty) return null;

    final plans = _plansBox.values.cast<DailyPlan>().toList();
    plans.sort((a, b) => b.date.compareTo(a.date)); // Most recent first

    return plans.first;
  }

  @override
  Future<List<DailyPlan>> getPlansForLastDays(int days) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final normalizedCutoff = DateTime(cutoffDate.year, cutoffDate.month, cutoffDate.day);

    final plans = _plansBox.values
        .cast<DailyPlan>()
        .where((plan) => plan.date.isAfter(normalizedCutoff) || plan.date.isAtSameMomentAs(normalizedCutoff))
        .toList();

    plans.sort((a, b) => b.date.compareTo(a.date)); // Most recent first

    return plans;
  }

  @override
  Future<void> markTaskCompleted(String planId, String taskId) async {
    // Find plan by ID
    DailyPlan? plan;
    String? planKey;

    for (var key in _plansBox.keys) {
      final p = _plansBox.get(key) as DailyPlan?;
      if (p?.id == planId) {
        plan = p;
        planKey = key as String;
        break;
      }
    }

    if (plan == null || planKey == null) return;

    // Update plan with completed task
    final updatedPlan = plan.markTaskCompleted(taskId);
    await _plansBox.put(planKey, updatedPlan);
  }

  @override
  Future<void> deletePlan(String planId) async {
    // Find and delete plan by ID
    for (var key in _plansBox.keys) {
      final plan = _plansBox.get(key) as DailyPlan?;
      if (plan?.id == planId) {
        await _plansBox.delete(key);
        break;
      }
    }
  }

  @override
  Future<bool> hasPlanForToday() async {
    final today = DateTime.now();
    final plan = await getPlanForDate(today);
    return plan != null;
  }
}
