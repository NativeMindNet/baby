# Implementation Plan: Daily Baby Coach MVP

**Version**: 1.0
**Date**: 2026-01-08
**Status**: Draft (awaiting approval)
**Based on**: [02-specifications.md](02-specifications.md) (approved 2026-01-08)

---

## Overview

This plan breaks down the implementation into **7 phases** over approximately **10-12 weeks**.

**Key Principles**:
- Build vertically (complete features end-to-end before moving to next)
- Test continuously (one feature at a time per CLAUDE.md)
- Deploy incrementally (each phase produces working software)

---

## Phase 0: Project Setup & Foundation (Week 1)

### Goals
- Create Flutter project structure
- Set up dependencies
- Configure CI/CD basics
- Establish coding standards

### Tasks

#### 0.1 Initialize Flutter Project
**Files**: `pubspec.yaml`, project structure
**Steps**:
1. Run `flutter create daily_baby_coach`
2. Configure iOS deployment target (15.0+)
3. Update `pubspec.yaml` with dependencies from specs
4. Run `flutter pub get`
5. Verify clean build: `flutter run`

**Testing**: App launches with default Flutter counter screen

---

#### 0.2 Set Up Project Structure
**Files**: Directory structure under `lib/`
**Steps**:
```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── colors.dart
│   └── localization/
│       └── localization_service.dart
├── domain/
│   ├── models/
│   ├── repositories/
│   └── services/
├── data/
│   ├── local/
│   ├── models/
│   └── repositories/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── providers/
└── main.dart
```

**Testing**: Project compiles with empty directories

---

#### 0.3 Configure Hive
**Files**:
- `lib/data/local/hive_setup.dart`
- `lib/main.dart`

**Steps**:
1. Create `HiveSetup` class with `init()` method
2. Register Hive adapters (placeholder for now)
3. Initialize Hive in `main()` before `runApp()`
4. Create boxes: `babyProfile`, `tasks`, `activityResults`, `skillScores`, `dailyPlans`

**Code**:
```dart
// hive_setup.dart
class HiveSetup {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters (will add in Phase 1)
    // Hive.registerAdapter(TaskAdapter());
    // ...

    // Open boxes
    await Hive.openBox('babyProfile');
    await Hive.openBox('tasks');
    await Hive.openBox('activityResults');
    await Hive.openBox('skillScores');
    await Hive.openBox('dailyPlans');
  }
}

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveSetup.init();
  runApp(const MyApp());
}
```

**Testing**: App launches, Hive boxes created (check with Hive DevTools)

---

#### 0.4 Set Up Theme & Dark Mode
**Files**:
- `lib/core/theme/app_theme.dart`
- `lib/core/theme/colors.dart`
- `lib/presentation/providers/theme_provider.dart`

**Steps**:
1. Define light theme colors
2. Define dark theme colors
3. Create `ThemeProvider` with Riverpod
4. Add manual toggle + system auto-detect
5. Update `MaterialApp` with theme providers

**Code**:
```dart
// colors.dart
class AppColors {
  // Light theme
  static const primaryLight = Color(0xFF6B9BD1);
  static const backgroundLight = Color(0xFFF8F9FA);

  // Dark theme (for sleep activities)
  static const primaryDark = Color(0xFF4A7BA7);
  static const backgroundDark = Color(0xFF1A1F2E);
}

// theme_provider.dart
enum ThemeMode { light, dark, system }

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final effectiveThemeModeProvider = Provider<Brightness>((ref) {
  final mode = ref.watch(themeModeProvider);
  if (mode == ThemeMode.system) {
    return SchedulerBinding.instance.window.platformBrightness;
  }
  return mode == ThemeMode.dark ? Brightness.dark : Brightness.light;
});
```

**Testing**:
- App displays in light mode by default
- Toggle to dark mode (manual)
- System theme change triggers app theme change

---

#### 0.5 Set Up Localization
**Files**:
- `lib/core/localization/localization_service.dart`
- `assets/i18n/en.json` (starter file)
- `pubspec.yaml` (add assets)

**Steps**:
1. Create `LocalizationService` class
2. Add JSON loader from assets
3. Create starter `en.json` with basic strings
4. Create Riverpod provider for localization
5. Update `pubspec.yaml` to include `assets/i18n/`

**Code**:
```dart
// localization_service.dart
class LocalizationService {
  Map<String, String> _strings = {};

  Future<void> load(String locale) async {
    final jsonString = await rootBundle.loadString('assets/i18n/$locale.json');
    final Map<String, dynamic> json = jsonDecode(jsonString);
    _strings = json.map((key, value) => MapEntry(key, value.toString()));
  }

  String t(String key) => _strings[key] ?? key;
}

// Provider
final localizationProvider = Provider<LocalizationService>((ref) {
  // Will be initialized in main()
  throw UnimplementedError();
});
```

**en.json** (starter):
```json
{
  "app_name": "Daily Baby Coach",
  "today_title": "Today",
  "loading": "Loading..."
}
```

**Testing**:
- App loads `en.json` successfully
- `t('app_name')` returns "Daily Baby Coach"

---

#### 0.6 Configure Firebase (Analytics & Crashlytics)
**Files**:
- iOS: `GoogleService-Info.plist`
- `lib/core/services/analytics_service.dart`
- `lib/main.dart`

**Steps**:
1. Create Firebase project in console
2. Register iOS app
3. Download `GoogleService-Info.plist` → `ios/Runner/`
4. Add Firebase SDK to iOS (via CocoaPods)
5. Initialize Firebase in `main()`
6. Create `AnalyticsService` wrapper

**Code**:
```dart
// analytics_service.dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await HiveSetup.init();
  runApp(const MyApp());
}
```

**Testing**:
- App launches without Firebase errors
- Firebase console shows first app open event

---

### Phase 0 Deliverable
✅ Flutter project with:
- Clean architecture structure
- Hive storage initialized
- Theme system (light/dark with manual toggle)
- Localization system (EN only)
- Firebase analytics connected
- All dependencies installed and working

---

## Phase 1: Data Models & Repository Layer (Week 2)

### Goals
- Implement all 5 core data models
- Generate Hive TypeAdapters
- Create repository interfaces and implementations
- Load initial task data

### Tasks

#### 1.1 Implement Task Model
**Files**:
- `lib/domain/models/task.dart`
- `lib/domain/models/skill_category.dart`

**Steps**:
1. Create `SkillCategory` enum
2. Create `Task` model with `@HiveType` annotations
3. Add JSON serialization methods (`fromJson`, `toJson`)
4. Run `build_runner` to generate adapter

**Code**:
```dart
// skill_category.dart
enum SkillCategory {
  regulation,
  attention,
  motor,
  causeEffect,
  communication,
  independence;

  String get displayName {
    switch (this) {
      case SkillCategory.regulation:
        return 'Calming';
      case SkillCategory.attention:
        return 'Attention';
      // ... etc
    }
  }

  String get icon {
    switch (this) {
      case SkillCategory.regulation:
        return '🧘';
      case SkillCategory.attention:
        return '👀';
      // ... etc
    }
  }
}

// task.dart
@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int minAgeDays;

  @HiveField(2)
  final int maxAgeDays;

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final SkillCategory category;

  @HiveField(5)
  final int difficulty;

  @HiveField(6)
  final String titleKey;

  @HiveField(7)
  final List<String> stepKeys;

  @HiveField(8)
  final String? stopIfKey;

  @HiveField(9)
  final String? fallbackTaskId;

  Task({...});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      minAgeDays: json['minAgeDays'],
      maxAgeDays: json['maxAgeDays'],
      durationMinutes: json['duration'],
      category: SkillCategory.values.byName(json['category']),
      difficulty: json['difficulty'],
      titleKey: json['titleKey'],
      stepKeys: List<String>.from(json['stepsKeys']),
      stopIfKey: json['stopIfKey'],
      fallbackTaskId: json['fallback'],
    );
  }

  Map<String, dynamic> toJson() => {...};
}
```

**Run**: `flutter pub run build_runner build`

**Testing**:
- Instantiate `Task` object
- Save to Hive box
- Retrieve from Hive box
- Verify all fields persisted

---

#### 1.2 Implement BabyProfile Model
**Files**: `lib/domain/models/baby_profile.dart`

**Steps**:
1. Create `BabyProfile` model with `@HiveType`
2. Add computed properties: `ageDays`, `ageMonths`
3. Generate adapter

**Code**:
```dart
@HiveType(typeId: 1)
class BabyProfile {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime birthDate;

  @HiveField(2)
  final Map<String, bool> capabilities;

  @HiveField(3)
  final DateTime lastCapabilityUpdate;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  BabyProfile({...});

  int get ageDays => DateTime.now().difference(birthDate).inDays;
  int get ageMonths => (ageDays / 30).floor();

  BabyProfile copyWith({...}) {...}
}
```

**Testing**:
- Create profile with birthdate 150 days ago
- Verify `ageDays` returns 150
- Verify `ageMonths` returns 5

---

#### 1.3 Implement ActivityResult, SkillScore, DailyPlan Models
**Files**:
- `lib/domain/models/activity_result.dart`
- `lib/domain/models/skill_score.dart`
- `lib/domain/models/daily_plan.dart`
- `lib/domain/models/feedback_score.dart`

**Steps**: Similar to 1.1 and 1.2
- Add `@HiveType` annotations
- Generate adapters
- Add computed properties where needed

**Testing**: Unit tests for each model

---

#### 1.4 Create TaskRepository
**Files**:
- `lib/domain/repositories/task_repository.dart` (interface)
- `lib/data/repositories/task_repository_impl.dart` (implementation)

**Steps**:
1. Define interface with methods: `initialize()`, `getTasksForAge()`, `getTasksForSkill()`, `getTaskById()`, `getFallbackTask()`
2. Implement using Hive box
3. Load tasks from `assets/tasks/tasks_en.json` during `initialize()`

**Code**:
```dart
// Interface
abstract class TaskRepository {
  Future<void> initialize();
  List<Task> getTasksForAge(int ageDays);
  List<Task> getTasksForSkill(SkillCategory skill, int ageDays);
  Task? getTaskById(String taskId);
  Task? getFallbackTask(String taskId);
}

// Implementation
class TaskRepositoryImpl implements TaskRepository {
  final Box _tasksBox = Hive.box('tasks');

  @override
  Future<void> initialize() async {
    if (_tasksBox.isNotEmpty) return; // Already loaded

    final jsonString = await rootBundle.loadString('assets/tasks/tasks_en.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);

    for (var json in jsonList) {
      final task = Task.fromJson(json);
      await _tasksBox.put(task.id, task);
    }
  }

  @override
  List<Task> getTasksForAge(int ageDays) {
    return _tasksBox.values
      .cast<Task>()
      .where((t) => t.minAgeDays <= ageDays && ageDays <= t.maxAgeDays)
      .toList();
  }

  // ... other methods
}
```

**Testing**:
- Load 5 sample tasks from JSON
- Call `getTasksForAge(150)` → verify returns correct tasks
- Call `getTasksForSkill(SkillCategory.attention, 150)` → verify filtering

---

#### 1.5 Create ProfileRepository
**Files**:
- `lib/domain/repositories/profile_repository.dart`
- `lib/data/repositories/profile_repository_impl.dart`

**Steps**:
1. CRUD methods: `getProfile()`, `saveProfile()`, `updateCapabilities()`
2. Use Hive box `babyProfile` with key `"current"`

**Testing**:
- Save profile
- Retrieve profile
- Update capabilities → verify persistence

---

#### 1.6 Create ActivityRepository & SkillScoreService
**Files**:
- `lib/domain/repositories/activity_repository.dart`
- `lib/data/repositories/activity_repository_impl.dart`
- `lib/domain/services/skill_score_service.dart`

**Steps**:
1. `ActivityRepository`: `recordResult()`, `getResultsForLast()`
2. `SkillScoreService`: `updateScoreAfterActivity()`, `getAllScores()`

**Testing**:
- Record 3 activities with different feedback scores
- Verify skill scores updated correctly
- Verify streaks calculated

---

#### 1.7 Create Sample Task JSON
**Files**: `assets/tasks/tasks_en.json`

**Steps**:
1. Create 10-20 sample tasks for MVP (we'll expand to 360 later)
2. Cover age range 120-210 days (4-7 months)
3. Include all 6 skill categories
4. Add to `pubspec.yaml` assets

**Sample**:
```json
[
  {
    "id": "attn_5m_01",
    "minAgeDays": 120,
    "maxAgeDays": 210,
    "duration": 5,
    "category": "attention",
    "difficulty": 2,
    "titleKey": "attn_5m_01_title",
    "stepsKeys": [
      "attn_5m_01_step_1",
      "attn_5m_01_step_2",
      "attn_5m_01_step_3"
    ],
    "stopIfKey": "attn_5m_01_stop",
    "fallback": "attn_4m_01"
  }
]
```

**Testing**: Load tasks via `TaskRepository.initialize()` → verify count

---

### Phase 1 Deliverable
✅ Complete data layer:
- 5 data models with Hive persistence
- 3 repositories implemented
- Sample task data loaded
- All unit tested

---

## Phase 2: Core Business Logic (Adaptive Engine) (Week 3)

### Goals
- Implement adaptive algorithm from specs
- Create daily plan generation service
- Test with various scenarios

### Tasks

#### 2.1 Implement AdaptiveEngine Service
**Files**: `lib/domain/services/adaptive_engine.dart`

**Steps**:
1. `generateDailyPlan()` method (main algorithm)
2. `_selectSkill()` helper (priority logic)
3. `_selectTask()` helper (difficulty matching)
4. Handle tough day mode

**Code**: Implement algorithm from specs section "Adaptive Algorithm"

**Testing**:
- Scenario 1: New user (no history) → generates 3 balanced tasks
- Scenario 2: User with easy streak → generates harder task
- Scenario 3: User with hard streak → generates fallback task
- Scenario 4: Tough day mode → generates 1 regulation task
- Scenario 5: Stale skill (unused 3+ days) → prioritizes it

---

#### 2.2 Create DailyPlanService
**Files**: `lib/domain/services/daily_plan_service.dart`

**Steps**:
1. Wrapper around AdaptiveEngine
2. Check if plan exists for today
3. If not, generate new plan
4. Store in Hive box `dailyPlans`

**Code**:
```dart
class DailyPlanService {
  final AdaptiveEngine _engine;
  final Box _plansBox = Hive.box('dailyPlans');

  Future<DailyPlan> getTodaysPlan({
    required BabyProfile profile,
    bool isToughDay = false,
  }) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Check cache
    if (_plansBox.containsKey(today) && !isToughDay) {
      return _plansBox.get(today);
    }

    // Generate new plan
    final skillScores = await _skillScoreService.getAllScores();
    final recentHistory = await _activityRepository.getResultsForLast(7);

    final plan = await _engine.generateDailyPlan(
      profile: profile,
      skillScores: skillScores,
      recentHistory: recentHistory,
      isToughDay: isToughDay,
    );

    await _plansBox.put(today, plan);
    return plan;
  }
}
```

**Testing**:
- First call → generates plan
- Second call same day → returns cached plan
- Tough day flag → regenerates even if cached

---

#### 2.3 Integration Tests for Adaptive Logic
**Files**: `test/integration/adaptive_engine_test.dart`

**Steps**: Create comprehensive test scenarios covering:
1. Complete user journey: Day 1-7
2. Various feedback patterns
3. Skill rotation logic
4. Edge cases (all tasks hard, all tasks easy)

---

### Phase 2 Deliverable
✅ Adaptive engine:
- Daily plan generation working
- All priority logic tested
- Integration tests passing

---

## Phase 3: Onboarding Flow (Week 4)

### Goals
- Create onboarding screens
- Collect baby profile
- Generate first daily plan
- Navigate to Today screen

### Tasks

#### 3.1 Create Onboarding Screens (UI)
**Files**:
- `lib/presentation/screens/onboarding/welcome_screen.dart`
- `lib/presentation/screens/onboarding/baby_age_screen.dart`
- `lib/presentation/screens/onboarding/capabilities_screen.dart`
- `lib/presentation/screens/onboarding/notifications_screen.dart`

**Steps**:
1. Welcome: Value proposition + "Get Started" button
2. Baby Age: Date picker or month selector
3. Capabilities: Checkbox list (8 capabilities from specs)
4. Notifications: Request permission + time picker

**Testing**:
- Navigate through all 4 screens
- Verify data collected in state

---

#### 3.2 Create Onboarding State Management
**Files**: `lib/presentation/providers/onboarding_provider.dart`

**Steps**:
1. State class: `birthDate`, `capabilities`, `notificationTime`
2. Methods: `setBirthDate()`, `toggleCapability()`, `setNotificationTime()`
3. `completeOnboarding()`: Save profile, schedule notification, generate first plan

**Code**:
```dart
class OnboardingState {
  final DateTime? birthDate;
  final Map<String, bool> capabilities;
  final TimeOfDay? notificationTime;

  OnboardingState({...});
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(OnboardingState(...));

  void setBirthDate(DateTime date) {
    state = state.copyWith(birthDate: date);
  }

  Future<void> completeOnboarding() async {
    // 1. Save profile
    final profile = BabyProfile(
      id: Uuid().v4(),
      birthDate: state.birthDate!,
      capabilities: state.capabilities,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastCapabilityUpdate: DateTime.now(),
    );
    await _profileRepository.saveProfile(profile);

    // 2. Schedule notification
    await _notificationService.scheduleDailyReminder(state.notificationTime!);

    // 3. Generate first plan
    await _dailyPlanService.getTodaysPlan(profile: profile);

    // 4. Mark onboarding complete
    await _prefs.setBool('onboardingComplete', true);
  }
}
```

**Testing**:
- Complete onboarding → verify profile saved
- Verify first plan generated
- Verify notification scheduled

---

#### 3.3 Implement App Entry Logic
**Files**: `lib/main.dart`

**Steps**:
1. Check if onboarding completed (SharedPreferences flag)
2. If yes → navigate to Today screen
3. If no → navigate to Welcome screen

**Code**:
```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: FutureBuilder<bool>(
        future: _checkOnboardingComplete(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SplashScreen();
          return snapshot.data! ? TodayScreen() : WelcomeScreen();
        },
      ),
    );
  }

  Future<bool> _checkOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboardingComplete') ?? false;
  }
}
```

**Testing**:
- First launch → shows Welcome screen
- After onboarding → shows Today screen
- Subsequent launches → shows Today screen

---

### Phase 3 Deliverable
✅ Onboarding complete:
- 4-screen flow implemented
- Profile creation working
- First plan generated
- App entry routing correct

---

## Phase 4: Today Screen (Week 5)

### Goals
- Display daily plan
- Show task cards
- Implement tough day mode
- Add theme toggle

### Tasks

#### 4.1 Create Today Screen UI
**Files**: `lib/presentation/screens/today/today_screen.dart`

**Steps**:
1. AppBar with settings icon + theme toggle
2. Header: "Today · X months Y days"
3. Task cards (ListView)
4. Tough day button
5. Progress indicator

**Layout** (from specs): See Today Screen wireframe

**Testing**:
- Screen loads with 3 task cards
- Tapping card navigates to Task Screen
- Theme toggle switches light/dark

---

#### 4.2 Create Task Card Widget
**Files**: `lib/presentation/widgets/task_card.dart`

**Steps**:
1. Display: skill icon, category name, duration, title
2. Completion checkmark if done
3. Tap handler → navigate to Task Screen

**Code**:
```dart
class TaskCard extends StatelessWidget {
  final Task task;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(task.category.icon, style: TextStyle(fontSize: 32)),
        title: Text(localization.t(task.titleKey)),
        subtitle: Text('${task.category.displayName} • ${task.durationMinutes} min'),
        trailing: isCompleted ? Icon(Icons.check_circle) : Icon(Icons.play_arrow),
        onTap: onTap,
      ),
    );
  }
}
```

**Testing**:
- Render 3 task cards
- Verify icons, titles, durations display correctly
- Tap card → navigates

---

#### 4.3 Implement Today Screen State Management
**Files**: `lib/presentation/providers/today_provider.dart`

**Steps**:
1. Load baby profile
2. Load today's plan
3. Load task details for each task ID
4. Track completion status

**Code**:
```dart
class TodayState {
  final BabyProfile? profile;
  final DailyPlan? plan;
  final List<Task> tasks;
  final bool isLoading;
  final String? error;

  TodayState({...});
}

final todayProvider = StateNotifierProvider<TodayNotifier, TodayState>((ref) {
  return TodayNotifier(
    profileRepository: ref.read(profileRepositoryProvider),
    dailyPlanService: ref.read(dailyPlanServiceProvider),
    taskRepository: ref.read(taskRepositoryProvider),
  );
});

class TodayNotifier extends StateNotifier<TodayState> {
  TodayNotifier({...}) : super(TodayState(isLoading: true)) {
    _loadTodayData();
  }

  Future<void> _loadTodayData() async {
    try {
      final profile = await _profileRepository.getProfile();
      final plan = await _dailyPlanService.getTodaysPlan(profile: profile!);
      final tasks = plan.taskIds
        .map((id) => _taskRepository.getTaskById(id))
        .whereType<Task>()
        .toList();

      state = TodayState(
        profile: profile,
        plan: plan,
        tasks: tasks,
        isLoading: false,
      );
    } catch (e) {
      state = TodayState(isLoading: false, error: e.toString());
    }
  }

  Future<void> activateToughDayMode() async {
    // Regenerate plan with isToughDay = true
    final newPlan = await _dailyPlanService.getTodaysPlan(
      profile: state.profile!,
      isToughDay: true,
    );
    await _loadTodayData(); // Refresh
  }
}
```

**Testing**:
- Load Today screen → 3 tasks displayed
- Tap "Tough day" → plan regenerates with 1 task
- Mark task complete → checkmark appears

---

#### 4.4 Add Skill Progress Indicators
**Files**: `lib/presentation/screens/today/skill_progress_widget.dart`

**Steps**:
1. Display 6 skill categories with comfort level indicators (●●●○)
2. Fetch from `SkillScoreService`
3. Show below task cards on Today screen

**Code**:
```dart
class SkillProgressWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scores = ref.watch(skillScoresProvider);

    return Column(
      children: [
        Text('Comfort Levels', style: Theme.of(context).textTheme.headline6),
        ...SkillCategory.values.map((skill) {
          final score = scores[skill]!;
          return Row(
            children: [
              Text(skill.icon),
              Text(skill.displayName),
              Spacer(),
              _buildDots(score.score), // ●●●○ based on score
            ],
          );
        }),
      ],
    );
  }

  Widget _buildDots(int score) {
    int level = ((score + 14) / 28 * 4).round(); // Map -14..+7 to 0..4
    return Row(
      children: List.generate(4, (i) {
        return Icon(i < level ? Icons.circle : Icons.circle_outline);
      }),
    );
  }
}
```

**Testing**:
- Display skill indicators
- Complete activities with different feedback → verify indicators update

---

#### 4.5 Add Theme Toggle to AppBar
**Files**: Update `lib/presentation/screens/today/today_screen.dart`

**Steps**:
1. Add icon button to AppBar
2. Show bottom sheet with 3 options: Light, Dark, System
3. Update theme provider on selection

**Code**:
```dart
IconButton(
  icon: Icon(Icons.brightness_6),
  onPressed: () {
    showModalBottomSheet(
      context: context,
      builder: (context) => ThemePickerSheet(),
    );
  },
)
```

**Testing**:
- Tap brightness icon → sheet appears
- Select "Dark" → app switches to dark mode
- Select "System" → app follows system theme

---

### Phase 4 Deliverable
✅ Today Screen complete:
- Daily plan displayed with 3 task cards
- Tough day mode functional
- Skill progress indicators visible
- Theme toggle working
- Navigation to Task Screen

---

## Phase 5: Task, Timer, Feedback Screens (Week 6-7)

### Goals
- Complete activity execution flow
- Implement timer
- Collect feedback
- Update skill scores

### Tasks

#### 5.1 Create Task Screen
**Files**: `lib/presentation/screens/task/task_screen.dart`

**Steps**:
1. Display task details: title, duration, category, steps, "stop if"
2. "Start Timer" button
3. Translate all strings using localization

**Layout**: See Task Screen wireframe in specs

**Testing**:
- Navigate from Today → Task screen
- Verify all task details displayed
- Tap "Start Timer" → navigates to Timer screen

---

#### 5.2 Create Timer Screen
**Files**: `lib/presentation/screens/timer/timer_screen.dart`

**Steps**:
1. Countdown timer (uses Dart `Timer.periodic`)
2. Pause/Resume button
3. Finish button
4. Auto-navigate to Feedback when timer reaches 0

**Code**:
```dart
class TimerScreen extends ConsumerStatefulWidget {
  final Task task;

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  late Timer _timer;
  late int _secondsRemaining;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.task.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _secondsRemaining--;
          if (_secondsRemaining <= 0) {
            _timer.cancel();
            _navigateToFeedback();
          }
        });
      }
    });
  }

  void _navigateToFeedback() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FeedbackScreen(task: widget.task)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;

    return Scaffold(
      appBar: AppBar(title: Text(localization.t(widget.task.titleKey))),
      body: Center(
        child: Column(
          children: [
            Text('$minutes:${seconds.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 72)),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _isPaused = !_isPaused),
                  child: Text(_isPaused ? 'Resume' : 'Pause'),
                ),
                ElevatedButton(
                  onPressed: _navigateToFeedback,
                  child: Text('Finish'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
```

**Testing**:
- Timer counts down correctly
- Pause/Resume works
- Finish button navigates to Feedback
- Timer reaches 0 → auto-navigates to Feedback

---

#### 5.3 Create Feedback Screen
**Files**: `lib/presentation/screens/feedback/feedback_screen.dart`

**Steps**:
1. 4 emoji buttons for feedback score
2. Duration picker (dropdown 1-20 minutes)
3. Optional comment text field
4. "Done" button → save result, navigate back to Today

**Code**:
```dart
class FeedbackScreen extends ConsumerStatefulWidget {
  final Task task;

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  FeedbackScore? _selectedScore;
  int _actualMinutes = 5;
  String _comment = '';

  Future<void> _submitFeedback() async {
    if (_selectedScore == null) return;

    final result = ActivityResult(
      id: Uuid().v4(),
      taskId: widget.task.id,
      completedAt: DateTime.now(),
      feedback: _selectedScore!,
      actualDurationMinutes: _actualMinutes,
      comment: _comment.isEmpty ? null : _comment,
      babyAgeDays: ref.read(profileProvider)!.ageDays,
    );

    // Save result
    await ref.read(activityRepositoryProvider).recordResult(result);

    // Update skill score
    await ref.read(skillScoreServiceProvider).updateScoreAfterActivity(
      widget.task.category,
      _selectedScore!,
    );

    // Log analytics
    ref.read(analyticsServiceProvider).logEvent('activity_completed', {
      'task_id': widget.task.id,
      'feedback': _selectedScore!.name,
      'actual_duration': _actualMinutes,
    });

    // Navigate back to Today
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('How did it go?')),
      body: Column(
        children: [
          // Emoji buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEmojiButton(FeedbackScore.easy, '👍', 'Easy'),
              _buildEmojiButton(FeedbackScore.normal, '😐', 'Good'),
              _buildEmojiButton(FeedbackScore.hard, '😣', 'Hard'),
              _buildEmojiButton(FeedbackScore.didNotWork, '⛔', 'No'),
            ],
          ),

          // Duration picker
          DropdownButton<int>(
            value: _actualMinutes,
            items: List.generate(20, (i) => i + 1)
              .map((m) => DropdownMenuItem(value: m, child: Text('$m min')))
              .toList(),
            onChanged: (val) => setState(() => _actualMinutes = val!),
          ),

          // Comment field
          TextField(
            decoration: InputDecoration(labelText: 'Any notes? (optional)'),
            onChanged: (val) => _comment = val,
          ),

          // Submit button
          ElevatedButton(
            onPressed: _selectedScore != null ? _submitFeedback : null,
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiButton(FeedbackScore score, String emoji, String label) {
    final isSelected = _selectedScore == score;
    return GestureDetector(
      onTap: () => setState(() => _selectedScore = score),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 48)),
            Text(label),
          ],
        ),
      ),
    );
  }
}
```

**Testing**:
- Select feedback emoji → button highlights
- Change duration → value updates
- Tap "Done" with no emoji → button disabled
- Tap "Done" with emoji → result saved, navigates to Today
- Verify Today screen shows task as completed

---

#### 5.4 Update Today Screen to Refresh After Feedback
**Files**: Update `lib/presentation/providers/today_provider.dart`

**Steps**:
1. Add `markTaskComplete(taskId)` method
2. Update completion status in daily plan
3. Refresh Today screen when navigating back

**Testing**:
- Complete activity → Today screen shows checkmark
- Complete all 3 activities → progress shows 3/3

---

### Phase 5 Deliverable
✅ Complete activity flow:
- Task → Timer → Feedback → Today (updated)
- Timer functional with pause/finish
- Feedback saves and updates skill scores
- Today screen reflects completions

---

## Phase 6: Profile, Notifications, Localization (Week 8)

### Goals
- Create profile settings screen
- Implement notification scheduling
- Add full localization strings
- Polish UI

### Tasks

#### 6.1 Create Profile Screen
**Files**: `lib/presentation/screens/profile/profile_screen.dart`

**Steps**:
1. Display baby age (non-editable birthdate)
2. Capability checkboxes
3. Notification time picker
4. Language selector
5. Theme mode picker

**Layout**: See Profile Screen wireframe in specs

**Testing**:
- Toggle capabilities → saved to profile
- Change notification time → rescheduled
- Change language → app reloads with new locale

---

#### 6.2 Implement Notification Service
**Files**: `lib/core/services/notification_service.dart`

**Steps**:
1. Request permission (iOS only)
2. Schedule daily notification at user-selected time
3. Schedule evening notification (7 PM) if sleep activity in plan

**Code**:
```dart
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
    FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const initializationSettings = InitializationSettings(
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(initializationSettings);
  }

  Future<bool> requestPermission() async {
    final result = await _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, sound: true);
    return result ?? false;
  }

  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await _plugin.zonedSchedule(
      0,
      'Time for today\'s activities',
      '3 quick activities ready',
      _nextInstanceOfTime(time),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }
}
```

**Testing**:
- Request permission → iOS permission dialog appears
- Schedule notification for 1 minute from now → notification arrives
- Tap notification → app opens to Today screen

---

#### 6.3 Complete EN Localization Strings
**Files**: `assets/i18n/en.json`

**Steps**:
1. Add all UI strings from all screens
2. Add sample task strings (for 10-20 MVP tasks)
3. Verify no hardcoded strings remain in code

**Sample**:
```json
{
  "app_name": "Daily Baby Coach",
  "today_title": "Today",
  "tough_day_button": "Having a tough day?",
  "start_timer": "Start Timer",
  "pause": "Pause",
  "resume": "Resume",
  "finish": "Finish",
  "feedback_title": "How did it go?",
  "feedback_easy": "Easy",
  "feedback_normal": "Just right",
  "feedback_hard": "Challenging",
  "feedback_failed": "Didn't work",

  "attn_5m_01_title": "Eye Contact Practice",
  "attn_5m_01_step_1": "Lay your baby on their back",
  "attn_5m_01_step_2": "Lean in about 30 cm from their face",
  "attn_5m_01_step_3": "Speak calmly for 20-30 seconds",
  "attn_5m_01_stop": "Stop if your baby turns away or cries"
}
```

**Testing**:
- Walk through entire app
- Verify all text displays correctly
- Check for any missing translation keys (should show key name)

---

#### 6.4 Polish UI & Add Loading States
**Files**: Various screen files

**Steps**:
1. Add loading spinners where needed (Today screen, Onboarding)
2. Add empty states (no tasks available)
3. Add error states with retry buttons
4. Improve spacing, padding, colors

**Testing**:
- Simulate slow loading → spinner displays
- Simulate empty task list → empty state message
- Simulate error → error message + retry button

---

### Phase 6 Deliverable
✅ Complete MVP features:
- Profile screen functional
- Notifications working
- Full EN localization
- Polished UI

---

## Phase 7: Testing, Bug Fixes, App Store Prep (Week 9-10)

### Goals
- Comprehensive testing
- Fix bugs
- Prepare App Store assets
- Submit to TestFlight

### Tasks

#### 7.1 Manual Testing Checklist
**Execute all scenarios from specs**:
- [ ] Onboarding for 0, 3, 6, 9, 12 month ages
- [ ] Daily plan generation for all skill combos
- [ ] Feedback loop: Easy → Harder task next day
- [ ] Feedback loop: Hard → Easier task next day
- [ ] Tough day mode: Reduced task count
- [ ] Offline mode: All features work without network
- [ ] Notification: Scheduled and delivered on time
- [ ] Dark mode: Sleep activities display correctly
- [ ] Theme toggle: Manual override works
- [ ] Skill progress: Indicators update correctly

#### 7.2 Fix Identified Bugs
**Create issues and fix systematically**

#### 7.3 Write Unit Tests
**Files**: `test/` directory
- Data models
- Repositories
- Services (AdaptiveEngine, SkillScoreService)

**Target**: >70% code coverage for business logic

#### 7.4 Write Widget Tests
**Files**: `test/widget/` directory
- Today Screen
- Task Screen
- Feedback Screen
- Onboarding screens

#### 7.5 Create App Store Assets
**Assets needed**:
1. App icon (1024x1024)
2. Screenshots (6.5" iPhone):
   - Today screen
   - Task screen
   - Timer screen
   - Skill progress
3. App description (EN)
4. Keywords
5. Privacy policy URL (simple static page)

#### 7.6 Configure iOS Signing & Certificates
**Steps**:
1. Create App ID in Apple Developer
2. Create provisioning profiles
3. Configure Xcode project
4. Archive build

#### 7.7 Submit to TestFlight
**Steps**:
1. Archive app in Xcode
2. Upload to App Store Connect
3. Fill metadata
4. Submit for TestFlight review
5. Invite beta testers

---

### Phase 7 Deliverable
✅ MVP ready for beta:
- All features tested
- Bugs fixed
- App submitted to TestFlight
- Beta testers invited

---

## Content Production (Parallel, Weeks 1-10)

### Tasks

#### C.1 Write 360 Tasks (EN)
**Deliverable**: `assets/tasks/tasks_en.json` with all 360 tasks
- 30 tasks per month × 12 months
- Cover all 6 skill categories
- Include difficulty levels 1-5
- Add fallback task IDs

**Timeline**: 2-3 weeks

#### C.2 Translate Task Strings to EN i18n
**Deliverable**: `assets/i18n/en.json` with ~1000+ keys
- All task titles
- All task steps
- All "stop if" guidance

**Timeline**: 1 week after C.1

#### C.3 (Optional) Translate to RU/TH/ZH
**Deliverable**: `ru.json`, `th.json`, `zh.json`
**Timeline**: Deferred to post-MVP (can launch EN-only)

---

## Risk Management

### High Risk Items
1. **Task content quality**: Inadequate or unsafe developmental advice
   - **Mitigation**: Partner with pediatric development expert for review

2. **Adaptive algorithm not effective**: Users don't perceive personalization
   - **Mitigation**: Extensive testing with beta users, gather feedback early

3. **User engagement low**: Users don't return daily
   - **Mitigation**: Notifications, simple UX, visible progress indicators

### Medium Risk Items
4. **App Store rejection**: Privacy, content, or technical issues
   - **Mitigation**: Follow guidelines strictly, avoid medical claims

5. **Performance issues**: Slow load times or crashes
   - **Mitigation**: Profile early, optimize Hive queries, test on older devices

---

## Decisions Made for Implementation

### Approved (2026-01-08)
1. **Task content review**: Will use general developmental guidelines, add disclaimer "not medical advice", defer expert review to beta phase
2. **Beta tester recruitment**: Target 30 beta testers (friends, family, parent communities)
3. **Analytics threshold**: Success = 40% D7 retention, 60% activity completion rate, <10% "didn't work" feedback
4. **Post-MVP priorities**:
   - P1: RU localization (developer can translate)
   - P2: Android version (leverage Flutter)
   - P3: Content expansion to full 360 tasks
   - P4: Video content (requires resources)

---

## Success Criteria for MVP

### Functional
- ✅ Complete onboarding → Today → Task → Timer → Feedback loop
- ✅ Daily plans generated with adaptive logic
- ✅ Notifications delivered
- ✅ Offline-first functionality
- ✅ Dark mode working

### Quality
- ✅ Crash-free rate >99%
- ✅ Cold start <2 seconds
- ✅ No critical bugs in TestFlight

### Engagement (Post-Launch Metrics)
- Target: 40%+ D7 retention
- Target: 60%+ activity completion rate
- Target: <10% "didn't work" feedback

---

## Post-MVP Roadmap (Not in Scope)

### Phase 8: Android Version (Weeks 11-13)
### Phase 9: RU/TH/ZH Localization (Weeks 14-15)
### Phase 10: Monetization (Paywall) (Weeks 16-17)
### Phase 11: Video Content (Weeks 18-22)
### Phase 12: Advanced AI Personalization (Weeks 23-28)

---

**Status**: ✅ APPROVED (2026-01-08) - Beginning implementation.

---

## Next Steps

Once plan is approved:
1. Start **Phase 0: Project Setup** (Week 1)
2. Create implementation log document (04-implementation-log.md)
3. Track progress against this plan
4. Update status.md after each phase

**Awaiting**: User approval to proceed with implementation.
