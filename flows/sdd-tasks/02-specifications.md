# Specifications: Task Content Structure

**Version**: 1.0
**Date**: 2026-01-09
**Status**: Draft

---

## Overview

This document specifies how 360 tasks will be structured, organized, and documented for the DailyBabyCoach app. All tasks follow the exact data structure defined in sdd-mvp.

---

## Current State Analysis

### Existing Content in Задания.md

**Month 5 (detailed)**: 20 tasks with full structure
- Categories present: "Внимание и зрение" (1-5), "Моторика" (6-10), "Слух и речь" (11-15), "Сон и регуляция" (16-20)
- Format: Title, Duration, Steps (numbered), Optional stop condition, Goal
- Durations: 2-6 minutes

**Months 0-4, 6-11 (minimal)**: 340 tasks as bullet points
- Format: Just title, sometimes with brief description
- Examples: "Контакт кожа-к-коже (5 мин)", "Медленный взгляд в лицо", "Пауза тишины"

### Mapping to 6 Skill Categories

**Existing categories** in Задания.md need to map to **6 exact categories** from sdd-mvp:

| Задания.md Category | Maps to sdd-mvp category |
|---------------------|--------------------------|
| Внимание и зрение | `attention` |
| Моторика | `motor` |
| Слух и речь | `communication` |
| Сон и регуляция | `regulation` |
| (implied) Причина-следствие | `cause_effect` |
| (implied) Самостоятельность | `independence` |

---

## Task Organization Strategy

### 1. Naming Convention

**Task IDs** will follow: `{category}_{monthGroup}_{number}`

**Category prefixes**:
- `reg_` - regulation tasks
- `attn_` - attention tasks
- `motor_` - motor tasks
- `cause_` - cause-effect tasks
- `comm_` - communication tasks
- `indep_` - independence tasks

**Month grouping** (flexible ranges, not strict):
- `0m` - 0-30 days
- `1m` - 30-60 days
- `2m` - 60-90 days
- `3m` - 90-120 days
- `4m` - 120-150 days
- `5m` - 150-180 days
- `6m` - 180-210 days
- `7m` - 210-240 days
- `8m` - 240-270 days
- `9m` - 270-300 days
- `10m` - 300-330 days
- `11m` - 330-365 days

**Examples**:
- `attn_5m_01` - First attention task for ~5 months
- `motor_3m_12` - 12th motor task for ~3 months
- `reg_0m_05` - 5th regulation task for newborns

### 2. Age Ranges (minAgeDays / maxAgeDays)

**Principle**: Age ranges should OVERLAP to allow flexibility

**Strategy**:
- Early months (0-3m): Narrower ranges (30-60 day spans)
- Middle months (4-7m): Medium ranges (60-90 day spans)
- Later months (8-11m): Wider ranges (90-120 day spans)

**Example progressions**:

| Task | minAgeDays | maxAgeDays | Span |
|------|------------|------------|------|
| attn_0m_01 | 0 | 45 | 1.5 months |
| attn_1m_01 | 30 | 75 | 1.5 months |
| attn_2m_01 | 60 | 120 | 2 months |
| attn_5m_01 | 150 | 210 | 2 months |
| attn_8m_01 | 240 | 330 | 3 months |

### 3. Difficulty Assignment

**Within each category**, tasks have difficulty 1-3:

**Difficulty 1 (Easy)**:
- Foundational, low-demand activities
- Minimal setup, very short duration (2-3 min)
- Examples: "Пауза тишины", "Наблюдение", "Контакт глаз"

**Difficulty 2 (Medium)**:
- Standard activities requiring some engagement
- Moderate duration (4-7 min)
- Examples: "Удержание взгляда", "Переворот с помощью", "Диалог звуками"

**Difficulty 3 (Hard)**:
- More complex, sustained activities
- Longer duration (7-10 min) or multiple steps
- Examples: "Ползание к цели", "Вставание с опорой", "Простые просьбы"

**Distribution target**: ~40% difficulty=1, ~40% difficulty=2, ~20% difficulty=3

### 4. Fallback Chain Strategy

**Rules**:
1. difficulty=1 tasks: fallback can be `null` or point to even earlier/simpler task
2. difficulty=2 tasks: fallback → difficulty=1 task in same category
3. difficulty=3 tasks: fallback → difficulty=2 or 1 task in same category

**Fallback should**:
- Be in the same skill category
- Have earlier age range (lower minAgeDays)
- Have lower or equal difficulty
- Create no circular references

**Example fallback chains**:

```
attn_8m_03 (diff=3) → attn_6m_05 (diff=2) → attn_4m_02 (diff=1) → null
motor_7m_08 (diff=2) → motor_5m_03 (diff=1) → motor_3m_01 (diff=1) → null
```

### 5. Duration Assignment

Based on analysis of existing content:

| Age Range | Typical Duration | Range |
|-----------|------------------|-------|
| 0-2 months | 2-3 min | 2-5 min |
| 3-5 months | 4-5 min | 3-7 min |
| 6-8 months | 5-6 min | 4-8 min |
| 9-11 months | 5-7 min | 4-10 min |

**Note**: Regulation/sleep tasks often shorter (2-3 min) regardless of age

---

## Category Mapping Detailed

### regulation (🧠 Регуляция)

**Covers**:
- Sleep preparation / self-soothing
- Calm-down activities
- Pauses / observation without stimulation
- Predictable rituals

**Examples from existing content**:
- "Зрительная пауза" (Month 5, task 5)
- "Спокойное завершение дня" (Month 5, task 16)
- "Пауза перед укачиванием" (Month 5, task 17)
- "Класть сонным" (Month 5, task 18)
- "Одинаковый жест" (Month 5, task 19)
- "Наблюдение" (Month 5, task 20)
- All tasks from "💤 Категория: Сон и регуляция" section

**Target count**: ~60-70 tasks (more in early months)

---

### attention (👀 Внимание)

**Covers**:
- Eye contact / gaze holding
- Visual tracking
- Focus on objects / faces
- Joint attention

**Examples from existing content**:
- "Удержание взгляда" (Month 5, task 1)
- "Медленное слежение" (Month 5, task 2)
- "Контрастный объект" (Month 5, task 3)
- "Реакция на мимику" (Month 5, task 4)
- All tasks from "🧠 Категория: Внимание и зрение" section

**Target count**: ~60 tasks

---

### motor (✋ Моторика)

**Covers**:
- Gross motor: rolling, crawling, sitting, standing
- Fine motor: grasping, reaching, transferring objects
- Body awareness / coordination

**Examples from existing content**:
- "Переворот с помощью" (Month 5, task 6)
- "Опора на руки" (Month 5, task 7)
- "Захват пальца" (Month 5, task 8)
- "Движение ног" (Month 5, task 9)
- "Свободное движение" (Month 5, task 10)
- All tasks from "🤲 Категория: Моторика" section

**Target count**: ~70 tasks (increases in later months)

---

### cause_effect (🔁 Причина-Следствие)

**Covers**:
- Understanding consequences of actions
- Object permanence (peek-a-boo, finding hidden items)
- Action-reaction games
- Problem-solving

**Examples from existing content** (implicit in current structure):
- "Убрать и вернуть предмет" (Month 7)
- "Катить предмет" (Month 7)
- "Простая причина–следствие" (Month 7)
- "Игрушка за тканью" (Month 7)
- "Заглянуть → найти" (Month 7)
- "Открыть → закрыть" (Month 9)

**Target count**: ~50 tasks (primarily 6-11 months)

---

### communication (💬 Коммуникация)

**Covers**:
- Sounds / babbling / vocal play
- Gestures (waving, pointing, giving)
- Turn-taking / proto-conversation
- Understanding simple words/requests

**Examples from existing content**:
- "Диалог звуками" (Month 5, task 11)
- "Медленная речь" (Month 5, task 12)
- "Пение без музыки" (Month 5, task 13)
- "Тихие звуки" (Month 5, task 14)
- "Имя ребёнка" (Month 5, task 15)
- All tasks from "👂 Категория: Слух и речь" section

**Target count**: ~60 tasks

---

### independence (🧩 Самостоятельность)

**Covers**:
- Self-initiated actions
- Independent play / exploration
- Waiting / patience
- Making choices

**Examples from existing content** (implicit):
- "Свободное движение" (Month 5, task 10) - could also be motor
- "Самостоятельная игра" (Month 9)
- "Выбор предмета" (Month 9)
- "Пауза без помощи" (Month 9)
- "Игра рядом, не вместе" (Month 9)
- "Ожидание" (Month 9)

**Target count**: ~50 tasks (increases in later months)

---

## Metadata Specification by Age Group

### Months 0-2 (Days 0-90)

**Characteristics**:
- Simplest activities
- Shortest durations (2-4 min)
- Focus on: regulation, attention, early motor
- High % of difficulty=1 tasks

**Target distribution** (60 tasks):
- regulation: 15 tasks
- attention: 15 tasks
- motor: 15 tasks
- cause_effect: 5 tasks
- communication: 8 tasks
- independence: 2 tasks

### Months 3-5 (Days 90-180)

**Characteristics**:
- Moderate complexity
- Medium durations (3-6 min)
- Balanced across categories
- Mix of difficulties

**Target distribution** (90 tasks):
- regulation: 12 tasks
- attention: 15 tasks
- motor: 20 tasks
- cause_effect: 12 tasks
- communication: 18 tasks
- independence: 13 tasks

### Months 6-8 (Days 180-270)

**Characteristics**:
- More complex interactions
- Longer durations (4-8 min)
- Motor and cause-effect increase
- More difficulty=2 and 3

**Target distribution** (120 tasks):
- regulation: 15 tasks
- attention: 18 tasks
- motor: 28 tasks
- cause_effect: 20 tasks
- communication: 22 tasks
- independence: 17 tasks

### Months 9-11 (Days 270-365)

**Characteristics**:
- Most complex activities
- Variable durations (4-10 min)
- High independence and communication
- More difficulty=3 tasks

**Target distribution** (90 tasks):
- regulation: 10 tasks
- attention: 12 tasks
- motor: 22 tasks
- cause_effect: 13 tasks
- communication: 17 tasks
- independence: 16 tasks

---

## Content Structure for Each Task

### Required Content (Russian)

Each task must have:

1. **Название (Title)**: Clear, concise (2-5 words)
   - Example: "Удержание взгляда", "Переворот с помощью"

2. **Шаги (Steps)**: 2-5 numbered steps
   - Clear, actionable instructions
   - Simple language
   - Each step = one action

3. **Условие остановки (Stop condition)**: When to end
   - Usually based on baby signals
   - Example: "Остановитесь, если ребёнок отворачивается"
   - Some tasks may not need explicit stop condition

4. **Цель (Goal)** - OPTIONAL in final structure
   - Will be used to inform category assignment
   - May be included in localization as "goalKey" if helpful for parents
   - Example: "концентрация внимания", "координация"

### i18n Key Mapping

For each task with id `{category}_{month}_{num}`, create keys:

- `{id}_title` - title
- `{id}_step_1` - first step
- `{id}_step_2` - second step
- ... (as many steps as needed)
- `{id}_stop` - stop condition

**Example for task `attn_5m_01`**:
```
Keys needed:
- attn_5m_01_title
- attn_5m_01_step_1
- attn_5m_01_step_2
- attn_5m_01_step_3
- attn_5m_01_step_4
- attn_5m_01_stop
```

---

## Adaptation Algorithm Specification

### Selection Algorithm

**Goal**: Pick 2-3 tasks per day that are balanced, age-appropriate, and adapted to baby's progress

**Inputs**:
- Baby's age in days
- Skill progress tracker (per-skill scores)
- Recent feedback history
- Yesterday's tasks (to avoid repetition)

**Steps**:

1. **Filter available tasks**:
   - Where `minAgeDays <= babyAge <= maxAgeDays`
   - Exclude tasks done in last 2 days
   - Result: pool of ~30-60 age-appropriate tasks

2. **Select skills for today**:
   - If any skill has `streak_hard >= 2`: prioritize that skill (easier task)
   - If any skill not used in 3+ days: include it
   - Otherwise: pick 2-3 skills with lowest recent usage
   - Ensure diversity (don't pick same skill twice unless necessary)

3. **Select difficulty per skill**:
   - For each selected skill:
     - If `streak_easy >= 2`: try difficulty +1 (if available)
     - If `last_result <= -1`: use fallback or difficulty -1
     - Otherwise: same difficulty as last time (or difficulty=1 if first time)

4. **Pick specific tasks**:
   - From filtered pool, matching selected skills and difficulties
   - Randomize among valid options (avoid same task repeatedly)
   - Final result: 2-3 tasks

**Pseudo-code**:
```
function selectDailyTasks(babyAge, skillProgress, history):
    available = filterByAge(allTasks, babyAge)
    available = excludeRecent(available, history, days=2)

    skills = selectSkillsForToday(skillProgress)  // 2-3 skills

    selectedTasks = []
    for skill in skills:
        difficulty = decideDifficulty(skill, skillProgress[skill])
        task = pickTask(available, skill, difficulty)
        selectedTasks.append(task)

    return selectedTasks
```

### Adaptation Rules

**After each task, parent provides feedback**: 👍 😐 😣 ⛔

**Update skill progress**:
```
if feedback == 👍 (easy):
    skill.score += 1
    skill.streak_easy += 1
    skill.streak_hard = 0

elif feedback == 😐 (normal):
    skill.score += 0
    skill.streak_easy = 0
    skill.streak_hard = 0

elif feedback == 😣 (hard):
    skill.score -= 1
    skill.streak_easy = 0
    skill.streak_hard += 1

elif feedback == ⛔ (failed):
    skill.score -= 2
    skill.streak_easy = 0
    skill.streak_hard += 1
```

**Difficulty adjustment**:
```
if skill.streak_easy >= 2:
    // Try harder task next time
    nextDifficulty = min(currentDifficulty + 1, 3)

elif skill.streak_hard >= 2:
    // Try easier task or fallback
    nextDifficulty = max(currentDifficulty - 1, 1)
    OR use task.fallback

else:
    // Keep same difficulty
    nextDifficulty = currentDifficulty
```

### Skill Rotation Strategy

**Goals**:
- All 6 skills get regular exposure
- Struggling skills get more attention
- Don't overload baby with too many new skills at once

**Rules**:
1. **Minimum rotation**: Each skill should appear at least once every 5 days
2. **Priority boost**: Skills with `streak_hard >= 2` get priority
3. **Balance**: Try to avoid 2 "hard" skills on same day
4. **Diversity**: Daily selections should span at least 2 different skills

**Skill selection weights**:
```
weight = baseWeight
if skill.last_used > 3 days ago:
    weight += 2  // boost unused skills

if skill.streak_hard >= 2:
    weight += 3  // boost struggling skills

if skill.score < -3:
    weight += 2  // boost low-scoring skills

// Randomly select skills with weighted probability
```

---

## Deliverables Structure

### 1. Task Content Document

**Format**: Markdown file with table

**Columns**:
- id
- title (RU)
- category
- minAgeDays / maxAgeDays
- duration
- difficulty
- steps (RU, numbered)
- stopIf (RU)
- fallback

**Example rows**:
| id | title | category | minAge | maxAge | duration | difficulty | steps | stopIf | fallback |
|----|-------|----------|--------|--------|----------|------------|-------|--------|----------|
| attn_5m_01 | Удержание взгляда | attention | 150 | 210 | 5 | 2 | 1. Положите ребёнка на спину<br>2. Наклонитесь на ~30 см<br>3. Спокойно говорите 20-30 сек<br>4. Пауза<br>5. Повторите 3 раза | Ребёнок отворачивается | attn_4m_01 |

### 2. i18n Key Mapping Document

**Format**: Markdown or CSV

Lists all i18n keys needed:
```
attn_5m_01_title
attn_5m_01_step_1
attn_5m_01_step_2
attn_5m_01_step_3
attn_5m_01_step_4
attn_5m_01_step_5
attn_5m_01_stop
```

### 3. Adaptation Algorithm Document

Already specified above, will be included in plan phase.

---

## Validation Checklist

Before content is complete, validate:

- [ ] All 360 tasks have unique IDs
- [ ] All tasks have all required fields
- [ ] All categories use exact 6 values
- [ ] All difficulty values are 1, 2, or 3
- [ ] All fallback IDs reference existing tasks
- [ ] No circular fallback references
- [ ] Age ranges are logical (maxAge > minAge)
- [ ] Distribution across categories is balanced (~50-70 per category)
- [ ] Distribution across difficulties is reasonable (~40% easy, ~40% medium, ~20% hard)
- [ ] Russian content is clear, safe, actionable
- [ ] All i18n keys are documented

---

## Next Steps

1. Begin mapping existing 360 tasks to the structure above
2. Assign categories based on content analysis
3. Determine age ranges based on developmental appropriateness
4. Assign difficulty based on complexity
5. Create fallback chains
6. Validate against checklist
7. Get user approval on specifications
8. Move to plan phase (detailed task-by-task breakdown)
