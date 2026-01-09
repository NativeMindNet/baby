import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/activity_result.dart';
import '../../domain/models/baby_profile.dart';
import '../../domain/models/daily_plan.dart';
import '../../domain/models/feedback_score.dart';
import '../../domain/models/skill_category.dart';
import '../../domain/models/skill_score.dart';
import '../../domain/models/task.dart';

/// Initializes Hive database and opens all required boxes
class HiveSetup {
  /// Initialize Hive and open all boxes
  static Future<void> init() async {
    // Initialize Hive with Flutter
    await Hive.initFlutter();

    // Register type adapters
    Hive.registerAdapter(SkillCategoryAdapter());        // typeId: 10
    Hive.registerAdapter(FeedbackScoreAdapter());        // typeId: 11
    Hive.registerAdapter(TaskAdapter());                 // typeId: 0
    Hive.registerAdapter(BabyProfileAdapter());          // typeId: 1
    Hive.registerAdapter(ActivityResultAdapter());       // typeId: 2
    Hive.registerAdapter(SkillScoreAdapter());           // typeId: 3
    Hive.registerAdapter(DailyPlanAdapter());            // typeId: 4

    // Open all boxes
    await Future.wait([
      Hive.openBox('babyProfile'),
      Hive.openBox('tasks'),
      Hive.openBox('activityResults'),
      Hive.openBox('skillScores'),
      Hive.openBox('dailyPlans'),
    ]);
  }

  /// Close all boxes (for testing or cleanup)
  static Future<void> close() async {
    await Hive.close();
  }
}
