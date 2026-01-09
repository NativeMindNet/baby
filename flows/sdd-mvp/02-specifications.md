# Specifications: Daily Baby Coach MVP

**Version**: 1.0
**Date**: 2026-01-08
**Status**: Draft (awaiting approval)
**Based on**: [01-requirements.md](01-requirements.md) (approved 2026-01-08)

---

## Technical Stack

### Platform
- **Primary Target**: iOS 15.0+
- **Framework**: Flutter 3.16+ (Dart 3.2+)
- **Build Target**: Native iOS app via Flutter build pipeline

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.0

  # Localization
  intl: ^0.18.1

  # Notifications
  flutter_local_notifications: ^16.0.0

  # Analytics & Crash Reporting
  firebase_core: ^2.24.0
  firebase_analytics: ^10.7.0
  firebase_crashlytics: ^3.4.0

dev_dependencies:
  hive_generator: ^2.0.0
  build_runner: ^2.4.0
```

### Architecture Pattern
**Clean Architecture with Riverpod**
```
lib/
├── core/                    # Shared utilities
│   ├── constants/
│   ├── theme/
│   └── localization/
├── domain/                  # Business logic
│   ├── models/
│   ├── repositories/
│   └── services/
├── data/                    # Data layer
│   ├── local/              # Hive storage
│   ├── models/             # DTOs
│   └── repositories/       # Implementations
└── presentation/           # UI layer
    ├── screens/
    ├── widgets/
    └── providers/
```

---

## Data Models

### 1. Task Model

**Purpose**: Represents a single developmental activity

```dart
@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;                    // e.g., "attn_5m_01"

  @HiveField(1)
  final int minAgeDays;               // e.g., 150

  @HiveField(2)
  final int maxAgeDays;               // e.g., 180

  @HiveField(3)
  final int durationMinutes;          // e.g., 5

  @HiveField(4)
  final SkillCategory category;       // enum

  @HiveField(5)
  final int difficulty;               // 1-5

  @HiveField(6)
  final String titleKey;              // i18n key

  @HiveField(7)
  final List<String> stepKeys;        // i18n keys

  @HiveField(8)
  final String? stopIfKey;            // i18n key (optional)

  @HiveField(9)
  final String? fallbackTaskId;       // easier alternative
}

enum SkillCategory {
  regulation,      // 🧘 Calming, self-soothing
  attention,       // 👀 Visual tracking, focus
  motor,           // 🤲 Gross/fine motor
  causeEffect,     // 🔁 Actions → results
  communication,   // 💬 Sounds, gestures
  independence     // 🧩 Self-play, autonomy
}
```

**Storage**:
- Bundled JSON file: `assets/tasks/tasks_en.json`
- Loaded into Hive box on app initialization
- 360 tasks pre-loaded

---

### 2. BabyProfile Model

**Purpose**: Stores baby's information and current capabilities

```dart
@HiveType(typeId: 1)
class BabyProfile {
  @HiveField(0)
  final String id;                    // UUID

  @HiveField(1)
  final DateTime birthDate;

  @HiveField(2)
  final Map<String, bool> capabilities; // e.g., {"rollsOver": true}

  @HiveField(3)
  final DateTime lastCapabilityUpdate;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  // Computed
  int get ageDays => DateTime.now().difference(birthDate).inDays;
  int get ageMonths => (ageDays / 30).floor();
}
```

**Capabilities Tracked** (boolean flags):
- `rollsOver`: Can roll from back to stomach
- `sitsWithSupport`: Can sit with minimal support
- `sitsIndependently`: Can sit without support
- `crawls`: Can crawl/scoot
- `standsWithSupport`: Can stand holding furniture
- `babbles`: Makes repetitive sounds (ba-ba, da-da)
- `respondsToName`: Turns head when name is called
- `selfSoothes`: Can calm down without always needing parent

**Storage**: Hive box `babyProfile`

---

### 3. ActivityResult Model

**Purpose**: Records completion and feedback for each activity

```dart
@HiveType(typeId: 2)
class ActivityResult {
  @HiveField(0)
  final String id;                    // UUID

  @HiveField(1)
  final String taskId;

  @HiveField(2)
  final DateTime completedAt;

  @HiveField(3)
  final FeedbackScore feedback;       // enum

  @HiveField(4)
  final int actualDurationMinutes;

  @HiveField(5)
  final String? comment;              // optional parent note

  @HiveField(6)
  final int babyAgeDays;              // snapshot at time of activity
}

enum FeedbackScore {
  easy(1),         // 👍 Too easy
  normal(0),       // 😐 Just right
  hard(-1),        // 😣 Challenging
  didNotWork(-2);  // ⛔ Failed/baby upset

  final int value;
  const FeedbackScore(this.value);
}
```

**Storage**: Hive box `activityResults`
**Retention**: Keep last 90 days, purge older entries

---

### 4. SkillScore Model

**Purpose**: Tracks progress and trends per skill category

```dart
@HiveType(typeId: 3)
class SkillScore {
  @HiveField(0)
  final SkillCategory skill;

  @HiveField(1)
  final int score;                    // sum of last 7 results (-14 to +7)

  @HiveField(2)
  final List<int> recentResults;      // last 7 feedback values

  @HiveField(3)
  final int streakEasy;               // consecutive easy completions

  @HiveField(4)
  final int streakHard;               // consecutive hard/failed

  @HiveField(5)
  final DateTime? lastUsed;           // last time skill was practiced

  @HiveField(6)
  final DateTime updatedAt;
}
```

**Computed Properties**:
```dart
bool get needsSupport => streakHard >= 2;
bool get needsChallenge => streakEasy >= 2;
bool get isStale => lastUsed == null ||
                    DateTime.now().difference(lastUsed!).inDays >= 3;
```

**Storage**: Hive box `skillScores`

---

### 5. DailyPlan Model

**Purpose**: The daily set of activities to present

```dart
@HiveType(typeId: 4)
class DailyPlan {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;                // date this plan is for

  @HiveField(2)
  final List<String> taskIds;         // 2-3 task IDs

  @HiveField(3)
  final bool isToughDayMode;          // simplified plan?

  @HiveField(4)
  final DateTime generatedAt;

  @HiveField(5)
  final Map<String, bool> completed;  // taskId -> completed status
}
```

**Generation Logic**: See [Adaptive Algorithm](#adaptive-algorithm) section

**Storage**: Hive box `dailyPlans`

---

## System Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Today Screen │  │ Task Screen  │  │Timer Screen  │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│         └──────────────────┴──────────────────┘              │
│                            │                                 │
│                   ┌────────▼────────┐                        │
│                   │   Providers     │ (Riverpod)             │
│                   └────────┬────────┘                        │
└────────────────────────────┼──────────────────────────────────┘
                             │
┌────────────────────────────▼──────────────────────────────────┐
│                      Domain Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │AdaptiveEngine│  │TaskRepository│  │ProfileRepo   │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└────────────────────────────┬──────────────────────────────────┘
                             │
┌────────────────────────────▼──────────────────────────────────┐
│                       Data Layer                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │ Hive Storage │  │  JSON Assets │  │Notifications │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└───────────────────────────────────────────────────────────────┘
```

---

## Core Services

### 1. AdaptiveEngine Service

**Responsibility**: Generate daily plans based on baby's age, skill scores, and history

```dart
class AdaptiveEngine {
  Future<DailyPlan> generateDailyPlan({
    required BabyProfile profile,
    required Map<SkillCategory, SkillScore> skillScores,
    required List<ActivityResult> recentHistory,
    required bool isToughDay,
  }) async {
    // Implementation detailed in Adaptive Algorithm section
  }

  SkillCategory selectNextSkill(
    Map<SkillCategory, SkillScore> scores
  ) {
    // Priority logic
  }

  Task selectTaskForSkill(
    SkillCategory skill,
    SkillScore score,
    BabyProfile profile,
    List<String> recentTaskIds,
  ) {
    // Task selection logic
  }
}
```

---

### 2. TaskRepository

**Responsibility**: Manage task data (load, query, filter)

```dart
class TaskRepository {
  Future<void> initialize() async {
    // Load tasks from assets/tasks/tasks_en.json
    // Store in Hive box 'tasks'
  }

  List<Task> getTasksForAge(int ageDays) {
    // Filter: minAgeDays <= ageDays <= maxAgeDays
  }

  List<Task> getTasksForSkill(
    SkillCategory skill,
    int ageDays,
  ) {
    // Filter by skill + age
  }

  Task? getTaskById(String taskId) {
    // Lookup by ID
  }

  Task? getFallbackTask(String taskId) {
    // Get easier alternative
  }
}
```

---

### 3. ProfileRepository

**Responsibility**: Manage baby profile CRUD operations

```dart
class ProfileRepository {
  Future<BabyProfile?> getProfile() async {
    // Load from Hive
  }

  Future<void> saveProfile(BabyProfile profile) async {
    // Save to Hive
  }

  Future<void> updateCapabilities(Map<String, bool> capabilities) async {
    // Update profile with new capabilities
  }
}
```

---

### 4. ActivityRepository

**Responsibility**: Record and query activity results

```dart
class ActivityRepository {
  Future<void> recordResult(ActivityResult result) async {
    // Save to Hive
    // Update skill scores
    // Trigger analytics event
  }

  List<ActivityResult> getResultsForLast(int days) {
    // Query recent results
  }

  List<ActivityResult> getResultsForSkill(
    SkillCategory skill,
    int days,
  ) {
    // Filter by skill
  }
}
```

---

### 5. SkillScoreService

**Responsibility**: Calculate and update skill progression

```dart
class SkillScoreService {
  Future<void> updateScoreAfterActivity(
    SkillCategory skill,
    FeedbackScore feedback,
  ) async {
    SkillScore current = await _getSkillScore(skill);

    // Add new result to recentResults (max 7)
    current.recentResults.add(feedback.value);
    if (current.recentResults.length > 7) {
      current.recentResults.removeAt(0);
    }

    // Recalculate score (sum of last 7)
    current.score = current.recentResults.reduce((a, b) => a + b);

    // Update streaks
    if (feedback == FeedbackScore.easy) {
      current.streakEasy++;
      current.streakHard = 0;
    } else if (feedback.value < 0) {
      current.streakHard++;
      current.streakEasy = 0;
    } else {
      current.streakEasy = 0;
      current.streakHard = 0;
    }

    current.lastUsed = DateTime.now();
    await _saveSkillScore(current);
  }

  Map<SkillCategory, SkillScore> getAllScores() {
    // Return all 6 skill scores
  }
}
```

---

## Adaptive Algorithm

### Daily Plan Generation Logic

**Inputs**:
- Baby's age (in days)
- 6 skill scores (current state)
- Recent activity history (last 7 days)
- Tough day mode flag

**Outputs**:
- 2-3 task IDs for today (or 1 if tough day mode)

**Algorithm**:

```dart
Future<DailyPlan> generateDailyPlan({
  required BabyProfile profile,
  required Map<SkillCategory, SkillScore> skillScores,
  required List<ActivityResult> recentHistory,
  required bool isToughDay,
}) async {
  int taskCount = isToughDay ? 1 : 3;
  List<String> selectedTaskIds = [];
  Set<SkillCategory> usedSkills = {};

  // Get task IDs used in last 3 days to avoid repeats
  Set<String> recentTaskIds = recentHistory
    .where((r) => DateTime.now().difference(r.completedAt).inDays <= 3)
    .map((r) => r.taskId)
    .toSet();

  for (int i = 0; i < taskCount; i++) {
    // Step 1: Select skill
    SkillCategory skill = _selectSkill(
      skillScores,
      usedSkills,
      isToughDay,
    );
    usedSkills.add(skill);

    // Step 2: Select task for skill
    Task? task = _selectTask(
      skill,
      skillScores[skill]!,
      profile,
      recentTaskIds,
      isToughDay,
    );

    if (task != null) {
      selectedTaskIds.add(task.id);
      recentTaskIds.add(task.id); // Avoid duplicates in same plan
    }
  }

  return DailyPlan(
    id: Uuid().v4(),
    date: DateTime.now(),
    taskIds: selectedTaskIds,
    isToughDayMode: isToughDay,
    generatedAt: DateTime.now(),
    completed: {for (var id in selectedTaskIds) id: false},
  );
}

SkillCategory _selectSkill(
  Map<SkillCategory, SkillScore> scores,
  Set<SkillCategory> usedSkills,
  bool isToughDay,
) {
  // Filter out already used skills
  var available = scores.entries
    .where((e) => !usedSkills.contains(e.key))
    .toList();

  // Priority 1: Tough day mode → prefer regulation
  if (isToughDay && !usedSkills.contains(SkillCategory.regulation)) {
    return SkillCategory.regulation;
  }

  // Priority 2: Skills with streakHard >= 2 (needs support)
  var needsSupport = available
    .where((e) => e.value.needsSupport)
    .toList();
  if (needsSupport.isNotEmpty) {
    return needsSupport.first.key;
  }

  // Priority 3: Stale skills (unused 3+ days)
  var stale = available
    .where((e) => e.value.isStale)
    .toList();
  if (stale.isNotEmpty) {
    return stale.first.key;
  }

  // Priority 4: Lowest score (least practiced)
  available.sort((a, b) => a.value.score.compareTo(b.value.score));
  return available.first.key;
}

Task? _selectTask(
  SkillCategory skill,
  SkillScore score,
  BabyProfile profile,
  Set<String> recentTaskIds,
  bool isToughDay,
) {
  // Get age-appropriate tasks for this skill
  var candidates = taskRepository
    .getTasksForSkill(skill, profile.ageDays)
    .where((t) => !recentTaskIds.contains(t.id))
    .toList();

  if (candidates.isEmpty) return null;

  // Determine target difficulty
  int targetDifficulty;
  if (isToughDay || score.streakHard >= 2) {
    targetDifficulty = 1; // Easy
  } else if (score.streakEasy >= 2) {
    targetDifficulty = 3; // Harder
  } else {
    targetDifficulty = 2; // Normal
  }

  // Find task closest to target difficulty
  candidates.sort((a, b) {
    int diffA = (a.difficulty - targetDifficulty).abs();
    int diffB = (b.difficulty - targetDifficulty).abs();
    return diffA.compareTo(diffB);
  });

  return candidates.first;
}
```

---

## Localization System

### i18n Structure

**File**: `assets/i18n/en.json`

```json
{
  "app_name": "Daily Baby Coach",
  "today_title": "Today",
  "start_timer": "Start",
  "finish_early": "Finish Early",
  "tough_day_button": "Having a tough day?",

  "feedback_how_was_it": "How did it go?",
  "feedback_easy": "Easy",
  "feedback_normal": "Just right",
  "feedback_hard": "Challenging",
  "feedback_failed": "Didn't work",

  "skill_regulation": "Calming",
  "skill_attention": "Attention",
  "skill_motor": "Movement",
  "skill_causeEffect": "Cause & Effect",
  "skill_communication": "Communication",
  "skill_independence": "Independence",

  "attn_5m_01_title": "Eye Contact Practice",
  "attn_5m_01_step_1": "Lay your baby on their back",
  "attn_5m_01_step_2": "Lean in about 30 cm from their face",
  "attn_5m_01_step_3": "Speak calmly for 20-30 seconds",
  "attn_5m_01_step_4": "Pause and repeat 3 times",
  "attn_5m_01_stop": "Stop if your baby turns away or cries"
}
```

**Loading**:
```dart
class LocalizationService {
  Map<String, String> _strings = {};

  Future<void> load(String locale) async {
    String jsonString = await rootBundle.loadString('assets/i18n/$locale.json');
    Map<String, dynamic> json = jsonDecode(jsonString);
    _strings = json.map((key, value) => MapEntry(key, value.toString()));
  }

  String t(String key) => _strings[key] ?? key;
}
```

**Usage**:
```dart
Text(localization.t('today_title'))
Text(localization.t(task.titleKey))
```

---

## Screen Specifications

### 1. Today Screen

**Route**: `/` (home)

**State**:
```dart
class TodayState {
  final BabyProfile profile;
  final DailyPlan plan;
  final List<Task> tasks;
  final Map<String, bool> completionStatus;
  final bool isLoading;
}
```

**Layout**:
```
┌─────────────────────────────────┐
│  Daily Baby Coach        [⚙️]   │  ← AppBar
├─────────────────────────────────┤
│                                 │
│  Today · 5 months 12 days       │  ← Header
│                                 │
│  ┌─────────────────────────┐   │
│  │ 🧘 Calming • 5 min      │   │  ← Task Card 1
│  │ Evening routine         │   │
│  │                  [▶️]    │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 👀 Attention • 7 min    │   │  ← Task Card 2
│  │ Eye tracking practice   │   │
│  │                  [▶️]    │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 🤲 Movement • 6 min     │   │  ← Task Card 3
│  │ Tummy time with support │   │
│  │                  [▶️]    │   │
│  └─────────────────────────┘   │
│                                 │
│  [😓 Having a tough day?]      │  ← Tough Day Button
│                                 │
│  Progress: 1/3 completed        │  ← Progress
└─────────────────────────────────┘
```

**Interactions**:
- Tap task card → Navigate to Task Screen
- Tap gear icon → Navigate to Profile Screen
- Tap "tough day" → Show confirmation, regenerate plan with 1 easy task

---

### 2. Task Screen

**Route**: `/task/:taskId`

**State**:
```dart
class TaskState {
  final Task task;
  final String translatedTitle;
  final List<String> translatedSteps;
  final String? translatedStopIf;
}
```

**Layout**:
```
┌─────────────────────────────────┐
│  [←]  Eye Contact Practice      │  ← AppBar
├─────────────────────────────────┤
│                                 │
│  ⏱️  5 minutes                   │  ← Duration
│  👀 Attention                    │  ← Category
│                                 │
│  What to do:                    │
│                                 │
│  1. Lay your baby on their back │  ← Steps
│  2. Lean in about 30 cm from    │
│     their face                  │
│  3. Speak calmly for 20-30      │
│     seconds                     │
│  4. Pause and repeat 3 times    │
│                                 │
│  ⚠️  Stop if your baby turns     │  ← Stop If
│      away or cries              │
│                                 │
│                                 │
│  [     Start Timer      ]       │  ← CTA Button
│                                 │
└─────────────────────────────────┘
```

**Interactions**:
- Tap "Start Timer" → Navigate to Timer Screen

---

### 3. Timer Screen

**Route**: `/timer/:taskId`

**State**:
```dart
class TimerState {
  final Task task;
  final int remainingSeconds;
  final bool isRunning;
  final bool isPaused;
}
```

**Layout**:
```
┌─────────────────────────────────┐
│  [←]  Eye Contact Practice      │
├─────────────────────────────────┤
│                                 │
│                                 │
│         ┌───────────┐           │
│         │           │           │
│         │   3:45    │           │  ← Timer Display
│         │           │           │
│         └───────────┘           │
│                                 │
│  💡 Tip: Watch for baby's       │  ← Mid-activity hint
│     engagement cues             │
│                                 │
│                                 │
│  [  ⏸️ Pause  ]  [  ⏹️ Finish  ] │  ← Controls
│                                 │
└─────────────────────────────────┘
```

**Interactions**:
- Timer counts down automatically
- Tap "Pause" → Pause timer
- Tap "Finish" → Navigate to Feedback Screen
- Timer reaches 0:00 → Auto-navigate to Feedback Screen

---

### 4. Feedback Screen

**Route**: `/feedback/:taskId`

**State**:
```dart
class FeedbackState {
  final Task task;
  final FeedbackScore? selectedScore;
  final int? actualMinutes;
  final String? comment;
}
```

**Layout**:
```
┌─────────────────────────────────┐
│  How did it go?                 │
├─────────────────────────────────┤
│                                 │
│  ┌────┐  ┌────┐  ┌────┐  ┌────┐│
│  │ 👍 │  │ 😐 │  │ 😣 │  │ ⛔ ││  ← Feedback Options
│  │Easy│  │Good│  │Hard│  │ No ││
│  └────┘  └────┘  └────┘  └────┘│
│                                 │
│  How many minutes?              │
│  [  5  ▼]                       │  ← Duration Picker
│                                 │
│  Any notes? (optional)          │
│  ┌─────────────────────────┐   │
│  │                         │   │  ← Comment Field
│  └─────────────────────────┘   │
│                                 │
│  [        Done       ]          │  ← Submit Button
│                                 │
└─────────────────────────────────┘
```

**Interactions**:
- Tap emoji → Select feedback score
- Select duration from dropdown (1-20 minutes)
- Optional: Add text comment
- Tap "Done" → Save result, update skill scores, navigate back to Today Screen

---

### 5. Profile Screen

**Route**: `/profile`

**State**:
```dart
class ProfileState {
  final BabyProfile profile;
  final Map<String, bool> capabilities;
}
```

**Layout**:
```
┌─────────────────────────────────┐
│  [←]  Baby Profile              │
├─────────────────────────────────┤
│                                 │
│  Birthday                       │
│  June 15, 2025                  │
│  (5 months, 12 days old)        │
│                                 │
│  ─────────────────────────────  │
│                                 │
│  What can baby do?              │
│                                 │
│  ☑️ Rolls over                   │
│  ☑️ Sits with support            │
│  ☐ Sits independently           │
│  ☐ Crawls                       │
│  ☑️ Babbles                      │
│  ☐ Responds to name             │
│  ☐ Self-soothes                 │
│                                 │
│  ─────────────────────────────  │
│                                 │
│  Notifications                  │
│  Daily reminder: 9:00 AM        │
│                                 │
│  Language                       │
│  English                  [▼]   │
│                                 │
└─────────────────────────────────┘
```

**Interactions**:
- Toggle capability checkboxes → Update profile
- Tap time → Edit notification schedule
- Tap language → Show language picker (EN/RU/TH/ZH)

---

## Edge Cases & Error Handling

### 1. First Launch (No Profile)
**Flow**:
- Show onboarding wizard
- Collect birthdate + initial capabilities
- Create profile
- Generate first daily plan
- Navigate to Today Screen

### 2. No Tasks Available for Age
**Cause**: Age falls outside all task ranges (shouldn't happen with 0-12 month coverage)
**Handling**:
- Fallback to closest age range tasks
- Log error to Crashlytics
- Show user-friendly message: "Generating activities..."

### 3. All Recent Tasks Completed
**Cause**: User very active, exhausted task pool for recent days
**Handling**:
- Allow task repeats after 2 days (reduce from 3-day window)
- Prioritize least-recently-used tasks

### 4. Tough Day Mode Multiple Times
**Cause**: User triggers tough day mode 3+ days in a row
**Handling**:
- Continue providing simplified plans
- After 3 days, show optional message: "Things settling down?" with option to return to normal mode

### 5. Feedback Skipped
**Cause**: User exits app during/after timer without submitting feedback
**Handling**:
- Mark task as completed (assume normal feedback)
- Do not update skill scores
- Next day, proceed with default difficulty

### 6. Offline Mode
**Cause**: No internet connection
**Handling**:
- All core features work offline (tasks, plans, profiles stored locally)
- Only analytics/crash reporting queued
- No user-facing error

### 7. Notification Permission Denied
**Cause**: User declines notification permission
**Handling**:
- App functions normally without push reminders
- Show in-app prompt on Profile Screen: "Enable notifications to remember daily activities"

---

## Data Storage Schema

### Hive Boxes

**Box: `babyProfile`** (single record)
- Key: `"current"`
- Value: `BabyProfile` object

**Box: `tasks`** (360 records)
- Key: Task ID (e.g., `"attn_5m_01"`)
- Value: `Task` object

**Box: `activityResults`** (append-only, 90-day retention)
- Key: UUID
- Value: `ActivityResult` object

**Box: `skillScores`** (6 records, one per skill)
- Key: `SkillCategory` enum name (e.g., `"attention"`)
- Value: `SkillScore` object

**Box: `dailyPlans`** (7-day rolling window)
- Key: Date string (e.g., `"2026-01-08"`)
- Value: `DailyPlan` object

---

## Notification Strategy

### Trigger Logic
- **Daily reminder**: User-configured time (default 9:00 AM local)
- **Evening sleep activity**: 7:00 PM local (if sleep activity in plan)

### Notification Content
**Title**: "Time for today's activities"
**Body**: "3 quick activities ready for [Baby Name]"
**Action**: Open app → Today Screen

### Scheduling
```dart
class NotificationService {
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // id
      'Time for today\'s activities',
      '3 quick activities ready',
      _nextInstanceOfTime(time),
      NotificationDetails(...),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: ...,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
```

---

## Analytics Events

### Events to Track (Firebase Analytics)

```dart
// App lifecycle
analytics.logAppOpen();
analytics.logEvent(name: 'onboarding_complete');

// Core actions
analytics.logEvent(name: 'daily_plan_viewed', parameters: {
  'baby_age_days': profile.ageDays,
  'task_count': plan.taskIds.length,
  'is_tough_day': plan.isToughDayMode,
});

analytics.logEvent(name: 'activity_started', parameters: {
  'task_id': task.id,
  'skill': task.category.name,
  'difficulty': task.difficulty,
});

analytics.logEvent(name: 'activity_completed', parameters: {
  'task_id': task.id,
  'feedback': result.feedback.name,
  'actual_duration': result.actualDurationMinutes,
});

analytics.logEvent(name: 'tough_day_activated');

// Progression
analytics.logEvent(name: 'skill_score_updated', parameters: {
  'skill': skillCategory.name,
  'new_score': updatedScore.score,
  'streak_easy': updatedScore.streakEasy,
  'streak_hard': updatedScore.streakHard,
});
```

---

## Performance Requirements

### Load Times
- App cold start → Today Screen: <2 seconds
- Task Screen load: <200ms
- Daily plan generation: <500ms
- Feedback submission: <100ms

### Memory
- Peak memory usage: <100 MB
- Hive database size: <5 MB (after 90 days of data)

### Battery
- Background work: None (no background fetch, no location services)
- Push notifications: System-managed, minimal impact

---

## Security & Privacy

### Data Privacy
- **No server sync**: All data stays on device
- **No account system**: No email, password, or PII collection
- **No analytics PII**: Only anonymized usage events
- **No third-party SDKs** beyond Firebase (Core, Analytics, Crashlytics)

### App Store Compliance
- Privacy nutrition label: "Data Not Linked to You" for analytics
- No COPPA concerns (app targets parents, not children)
- No IDFA tracking
- No web views with user-generated content

---

## Testing Strategy

### Unit Tests
- `AdaptiveEngine`: Skill selection logic, task selection logic
- `SkillScoreService`: Score calculation, streak logic
- `TaskRepository`: Filtering by age, skill, difficulty

### Widget Tests
- `TodayScreen`: Render task cards, tough day button
- `TaskScreen`: Display steps, timer CTA
- `FeedbackScreen`: Emoji selection, form submission

### Integration Tests
- Complete flow: Onboarding → Today → Task → Timer → Feedback → Today (updated)
- Tough day mode: Activation → Simplified plan generation
- Profile updates: Change capabilities → See adjusted task difficulty

### Manual Testing Checklist
- [ ] Onboarding for 0, 3, 6, 9, 12 month ages
- [ ] Daily plan generation for all skill combos
- [ ] Feedback loop: Easy → Harder task next day
- [ ] Feedback loop: Hard → Easier task next day
- [ ] Tough day mode: Reduced task count
- [ ] Localization: EN, RU, TH, ZH (all strings present)
- [ ] Offline mode: All features work without network
- [ ] Notification: Scheduled and delivered on time
- [ ] Dark mode: Sleep activities display correctly

---

## Dependencies on External Assets

### Content Files (Required for MVP)
1. **Task JSON**: `assets/tasks/tasks_en.json` (360 tasks)
2. **Localization JSON**:
   - `assets/i18n/en.json`
   - `assets/i18n/ru.json` (deferred)
   - `assets/i18n/th.json` (deferred)
   - `assets/i18n/zh.json` (deferred)

### Design Assets
- App icon (1024x1024 PNG)
- Launch screen (iOS storyboard)
- Skill category icons (6 SVGs)
- Empty state illustrations (optional, can use text-only)

---

## Technical Decisions Made

### Approved (2026-01-08)
1. **Content delivery**: ✅ Bundled JSON (simple, offline-first)
2. **Notification library**: ✅ `flutter_local_notifications` (cross-platform ready)
3. **Dark mode**: ✅ System auto-switch + manual toggle (prominent in UI, for daytime naps)
4. **Baby profile**: ✅ Single profile only (no multi-child in MVP)
5. **Skill score visibility**: ✅ Show progression indicators (engagement + feedback understanding)

---

## Next Steps

Once specifications are approved:
1. Create **Plan document** (03-plan.md) with:
   - Task breakdown (file-by-file)
   - Implementation order
   - Dependencies and blockers
   - Testing milestones
2. Begin implementation following the plan

---

**Status**: ✅ APPROVED (2026-01-08) - Proceeding to planning phase.
