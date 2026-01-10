# Task Structure Reference (from sdd-mvp)

**Source**: flows/sdd-mvp/02-specifications.md, flows/sdd-mvp/03-plan.md

This document defines the exact structure that all 360 tasks must follow.

---

## Task Object Structure

Each task has exactly these fields (defined in sdd-mvp):

```dart
class Task {
  final String id;                    // Task identifier
  final int minAgeDays;               // Minimum age in days
  final int maxAgeDays;               // Maximum age in days
  final int duration;                 // Duration in minutes
  final String category;              // Skill category (one of 6)
  final int difficulty;               // Difficulty level 1-3
  final String titleKey;              // i18n key for title
  final List<String> stepsKeys;       // i18n keys for steps
  final String stopIfKey;             // i18n key for stop condition
  final String? fallback;             // Fallback task ID (nullable)
}
```

---

## Field Specifications

### `id` (String, required)
- **Format**: `{skill}_{month}m_{number}` or `{skill}_{number}`
- **Examples**:
  - `"attn_5m_01"` - attention task for ~5 months, #1
  - `"motor_3m_12"` - motor task for ~3 months, #12
  - `"regulation_01"` - regulation task (month-agnostic numbering)
- **Naming convention**:
  - skill: `regulation`, `attention`, `motor`, `cause_effect`, `communication`, `independence`
  - month: `0m`, `1m`, `2m`, ..., `11m` (optional, for organizational purposes)
  - number: `01`, `02`, ... `30` (zero-padded)

### `minAgeDays` (int, required)
- Minimum age in days when this task becomes appropriate
- **Example**: 150 (5 months ≈ 150 days)
- **Range**: 0 - 365 (0-12 months)
- **Note**: Not strict boundaries - tasks can span multiple months

### `maxAgeDays` (int, required)
- Maximum age in days when this task is still appropriate
- **Example**: 210 (7 months ≈ 210 days)
- **Must be**: > minAgeDays
- **Typical span**: 60-120 days (2-4 months overlap)

### `duration` (int, required)
- Expected duration in minutes
- **Range**: 2-10 minutes typical
- **Examples**: 3, 5, 7, 10
- **Note**: Short activities parents can do anytime

### `category` (String, required)
- **Must be exactly one of**:
  - `"regulation"` - 🧠 Саморегуляция, успокоение
  - `"attention"` - 👀 Внимание, фокус
  - `"motor"` - ✋ Моторика (крупная и мелкая)
  - `"cause_effect"` - 🔁 Причина-следствие
  - `"communication"` - 💬 Коммуникация (звуки, жесты, речь)
  - `"independence"` - 🧩 Самостоятельность, инициатива
- **No other values allowed** (defined by SkillCategory enum in sdd-mvp)

### `difficulty` (int, required)
- Difficulty level within the skill category
- **Values**:
  - `1` - Easy (базовый уровень)
  - `2` - Medium (средний уровень)
  - `3` - Hard (сложный уровень)
- **Relative to skill**: difficulty is relative within each category
  - A difficulty=1 task for 8-month-old is harder than difficulty=1 for 2-month-old
  - But both are "easy" for their respective age

### `titleKey` (String, required)
- i18n translation key for task title
- **Format**: `{skill}_{month}m_{number}_title`
- **Example**: `"attn_5m_01_title"`
- **Will map to** (in localization):
  - RU: "Удержание взгляда"
  - EN: "Eye Contact Practice"
  - etc.

### `stepsKeys` (List<String>, required)
- Array of i18n keys for task steps
- **Format**: `["{skill}_{month}m_{number}_step_1", "_step_2", ...]`
- **Example**: `["attn_5m_01_step_1", "attn_5m_01_step_2", "attn_5m_01_step_3"]`
- **Typical length**: 3-5 steps
- **Each step**: One clear, actionable instruction

### `stopIfKey` (String, required)
- i18n key for stop condition (when to end task early)
- **Format**: `{skill}_{month}m_{number}_stop`
- **Example**: `"attn_5m_01_stop"`
- **Will map to**: "Остановитесь, если ребёнок отворачивается или плачет"
- **Purpose**: Safety guidance for parents

### `fallback` (String?, nullable)
- Task ID to use if this task is too hard for the baby
- **Example**: `"attn_3m_02"` (earlier/easier task in same skill)
- **Can be null**: For easiest (difficulty=1) tasks or foundational tasks
- **Must reference**: Valid task ID that exists
- **Typically**: Points to earlier month or lower difficulty in same skill
- **No circular references**: fallback chains must eventually terminate

---

## Example Task (Complete)

```json
{
  "id": "attn_5m_01",
  "minAgeDays": 150,
  "maxAgeDays": 210,
  "duration": 5,
  "category": "attention",
  "difficulty": 2,
  "titleKey": "attn_5m_01_title",
  "stepsKeys": [
    "attn_5m_01_step_1",
    "attn_5m_01_step_2",
    "attn_5m_01_step_3",
    "attn_5m_01_step_4"
  ],
  "stopIfKey": "attn_5m_01_stop",
  "fallback": "attn_4m_01"
}
```

**Corresponding Russian content** (handled separately in localization):
- `attn_5m_01_title`: "Удержание взгляда"
- `attn_5m_01_step_1`: "Положите ребёнка на спину"
- `attn_5m_01_step_2`: "Наклонитесь на расстояние ~30 см"
- `attn_5m_01_step_3`: "Спокойно говорите 20–30 сек"
- `attn_5m_01_step_4`: "Сделайте паузу и повторите 3 раза"
- `attn_5m_01_stop`: "Остановитесь, если ребёнок отворачивается"

---

## Validation Rules

For content to be valid:

1. ✅ All required fields present
2. ✅ `category` is one of the 6 exact values
3. ✅ `difficulty` is 1, 2, or 3
4. ✅ `maxAgeDays` > `minAgeDays`
5. ✅ `duration` is reasonable (2-10 min typically)
6. ✅ `fallback` references a valid task ID (if not null)
7. ✅ `stepsKeys` has at least 2-3 steps
8. ✅ All keys follow naming convention
9. ✅ No circular fallback references

---

## Content vs Implementation Separation

**In sdd-tasks (content work)**:
- Define task metadata (id, ages, duration, category, difficulty, fallback)
- Write Russian content (title, steps, stop condition)
- Document which i18n keys each task needs
- ❌ Do NOT create actual JSON files
- ❌ Do NOT create i18n translation files

**Later (in implementation)**:
- Create actual `tasks_en.json` file with task metadata
- Create `ru.json`, `en.json`, etc. with translations
- Load tasks into app

---

## Summary

All 360 tasks must be documented with:
1. **Complete metadata** following exact structure above
2. **Russian content** for title, steps, stop condition
3. **i18n key mapping** (which keys correspond to which content)
4. **Validation** that all rules are met

This content will then be used by developers to create the actual JSON/localization files.
