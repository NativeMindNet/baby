import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/activity_repository_impl.dart';
import '../../data/repositories/daily_plan_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/activity_repository.dart';
import '../../domain/repositories/daily_plan_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/services/adaptive_engine.dart';
import '../../domain/services/daily_plan_service.dart';
import '../../domain/services/skill_score_service.dart';

/// Provider for TaskRepository
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl();
});

/// Provider for ProfileRepository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

/// Provider for ActivityRepository
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return ActivityRepositoryImpl(taskRepository);
});

/// Provider for DailyPlanRepository
final dailyPlanRepositoryProvider = Provider<DailyPlanRepository>((ref) {
  return DailyPlanRepositoryImpl();
});

/// Provider for SkillScoreService
final skillScoreServiceProvider = Provider<SkillScoreService>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return SkillScoreService(taskRepository);
});

/// Provider for AdaptiveEngine
final adaptiveEngineProvider = Provider<AdaptiveEngine>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final profileRepository = ref.watch(profileRepositoryProvider);
  final skillScoreService = ref.watch(skillScoreServiceProvider);
  return AdaptiveEngine(taskRepository, profileRepository, skillScoreService);
});

/// Provider for DailyPlanService
final dailyPlanServiceProvider = Provider<DailyPlanService>((ref) {
  final planRepository = ref.watch(dailyPlanRepositoryProvider);
  final taskRepository = ref.watch(taskRepositoryProvider);
  final adaptiveEngine = ref.watch(adaptiveEngineProvider);
  return DailyPlanService(planRepository, taskRepository, adaptiveEngine);
});
