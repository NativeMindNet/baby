import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/daily_plan.dart';
import '../../domain/models/task.dart';
import '../../domain/services/daily_plan_service.dart';
import 'repository_providers.dart';

/// State for Today screen
class TodayState {
  final DailyPlan? plan;
  final List<Task> tasks;
  final bool isLoading;
  final String? error;

  const TodayState({
    this.plan,
    this.tasks = const [],
    this.isLoading = false,
    this.error,
  });

  TodayState copyWith({
    DailyPlan? plan,
    List<Task>? tasks,
    bool? isLoading,
    String? error,
  }) {
    return TodayState(
      plan: plan ?? this.plan,
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// State notifier for Today screen
class TodayNotifier extends StateNotifier<TodayState> {
  final DailyPlanService _dailyPlanService;

  TodayNotifier(this._dailyPlanService) : super(const TodayState()) {
    loadTodaysPlan();
  }

  /// Load or generate today's plan
  Future<void> loadTodaysPlan({bool isToughDayMode = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final plan = await _dailyPlanService.getTodaysPlan(
        isToughDayMode: isToughDayMode,
      );

      final tasks = _dailyPlanService.getTasksForPlan(plan);

      state = TodayState(
        plan: plan,
        tasks: tasks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Regenerate today's plan (e.g., after toggling tough day mode)
  Future<void> regeneratePlan({bool isToughDayMode = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final plan = await _dailyPlanService.regenerateTodaysPlan(
        isToughDayMode: isToughDayMode,
      );

      final tasks = _dailyPlanService.getTasksForPlan(plan);

      state = TodayState(
        plan: plan,
        tasks: tasks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Mark a task as completed
  Future<void> markTaskCompleted(String taskId) async {
    if (state.plan == null) return;

    try {
      await _dailyPlanService.markTaskCompleted(state.plan!.id, taskId);

      // Reload plan to reflect updated completion status
      await loadTodaysPlan(isToughDayMode: state.plan!.isToughDayMode);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Refresh the plan
  Future<void> refresh() async {
    await loadTodaysPlan(
      isToughDayMode: state.plan?.isToughDayMode ?? false,
    );
  }
}

/// Provider for Today screen state
final todayProvider = StateNotifierProvider<TodayNotifier, TodayState>((ref) {
  final dailyPlanService = ref.watch(dailyPlanServiceProvider);
  return TodayNotifier(dailyPlanService);
});
