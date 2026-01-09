/// Application-wide constants
class AppConstants {
  // Version
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  // Storage keys
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String themeModeKey = 'theme_mode';

  // Hive box names
  static const String babyProfileBox = 'babyProfile';
  static const String tasksBox = 'tasks';
  static const String activityResultsBox = 'activityResults';
  static const String skillScoresBox = 'skillScores';
  static const String dailyPlansBox = 'dailyPlans';

  // Age ranges (in days)
  static const int maxAgeDays = 365; // 12 months
  static const int tasksPerMonth = 30;
  static const int totalTasks = 360;

  // Activity settings
  static const int minActivityDurationMinutes = 1;
  static const int maxActivityDurationMinutes = 20;
  static const int defaultActivityDurationMinutes = 5;

  // Plan settings
  static const int normalPlanTaskCount = 3;
  static const int toughDayTaskCount = 1;
  static const int recentTaskWindowDays = 3;

  // Skill score settings
  static const int skillScoreHistoryLength = 7; // Last 7 results
  static const int streakThreshold = 2; // 2 consecutive for action

  // Data retention
  static const int activityResultsRetentionDays = 90;
  static const int dailyPlansRetentionDays = 7;

  // Notification defaults
  static const int defaultNotificationHour = 9;
  static const int defaultNotificationMinute = 0;
  static const int eveningNotificationHour = 19; // 7 PM

  // Analytics event names
  static const String eventAppOpen = 'app_open';
  static const String eventOnboardingComplete = 'onboarding_complete';
  static const String eventDailyPlanViewed = 'daily_plan_viewed';
  static const String eventActivityStarted = 'activity_started';
  static const String eventActivityCompleted = 'activity_completed';
  static const String eventToughDayActivated = 'tough_day_activated';
  static const String eventSkillScoreUpdated = 'skill_score_updated';

  // Error messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNoTasks = 'No activities available for this age.';
  static const String errorNoProfile = 'Please complete onboarding first.';
}
