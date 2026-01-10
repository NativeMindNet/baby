# Plan: Task Content Mapping & Refinement

**Version**: 1.0
**Date**: 2026-01-09
**Status**: Draft

---

## Overview

This document outlines the detailed plan for mapping and refining all 360 tasks from `Задания.md` into the structured format defined in specifications.

---

## Approach

### Phase 1: Establish Baseline (Month 5 - Already Detailed)

**Input**: 20 detailed tasks from Month 5 in `Задания.md`
**Output**: Fully structured Month 5 tasks as reference examples

These will serve as the "gold standard" for formatting the remaining 340 tasks.

### Phase 2: Map Remaining Months (0-4, 6-11)

**Input**: 340 bullet-point tasks across 11 months
**Output**: Fully structured tasks with metadata

Strategy: Month by month, assign categories, expand content, add metadata

### Phase 3: Create Fallback Chains

**Input**: All 360 tasks with categories and difficulties
**Output**: Valid fallback references for all difficulty=2 and 3 tasks

### Phase 4: Validate & Balance

**Input**: Complete 360-task dataset
**Output**: Validated, balanced content ready for implementation

---

## Detailed Task Breakdown

### Task 1: Month 5 - Reference Implementation

**Goal**: Convert the 20 existing detailed Month 5 tasks into the full structure

**Input** (from Задания.md lines 18-248):
- 20 tasks with detailed structure
- Existing categories: "Внимание и зрение" (5), "Моторика" (5), "Слух и речь" (5), "Сон и регуляция" (5)

**Process**:
1. For each of the 20 tasks:
   - Assign ID (following naming convention)
   - Map to one of 6 categories
   - Set age range (minAgeDays: 150, maxAgeDays: ~210)
   - Assign difficulty (1-3 based on complexity)
   - Extract title, steps, stop condition
   - Determine fallback (reference earlier month tasks)

**Expected Output**: [tasks-month-5.md](flows/sdd-tasks/tasks/tasks-month-5.md)

**Example transformation**:

**Before** (from Задания.md):
```
### **1️⃣ Удержание взгляда**
⏱ 5 мин
Что делать:
1. Положите ребёнка на спину
2. Наклонитесь на расстояние ~30 см
3. Спокойно говорите 20–30 сек
4. Сделайте паузу
5. Повторите 3 раза
Остановиться, если: ребёнок отворачивается
Цель: концентрация внимания
```

**After**:
| id | title | category | minAge | maxAge | duration | difficulty | steps | stopIf | fallback |
|----|-------|----------|--------|--------|----------|------------|-------|--------|----------|
| attn_5m_01 | Удержание взгляда | attention | 150 | 210 | 5 | 2 | 1. Положите ребёнка на спину<br>2. Наклонитесь на расстояние ~30 см<br>3. Спокойно говорите 20–30 сек<br>4. Сделайте паузу<br>5. Повторите 3 раза | Ребёнок отворачивается | attn_3m_01 |

**Estimated effort**: ~2-3 hours

---

### Task 2: Month 0 - Newborn Tasks

**Goal**: Map and refine 30 tasks for newborns (0-30 days)

**Input** (from Задания.md lines 307-340):
- 30 bullet-point tasks
- Examples: "Контакт кожа-к-коже", "Спокойное дыхание рядом", "Тихий голос возле уха"

**Category distribution target**:
- regulation: 10 tasks (high for newborns)
- attention: 7 tasks
- motor: 7 tasks
- cause_effect: 2 tasks
- communication: 3 tasks
- independence: 1 task

**Process**:
1. Read all 30 task titles
2. Categorize based on content
3. Expand minimal titles into full structure (title + 2-4 steps + stop condition)
4. Assign metadata:
   - minAgeDays: 0
   - maxAgeDays: 45-60 (overlap with month 1)
   - duration: 2-4 min (very short for newborns)
   - difficulty: mostly 1 (easy), some 2
5. Assign fallbacks (mostly null for difficulty=1)

**Expected Output**: [tasks-month-0.md](flows/sdd-tasks/tasks/tasks-month-0.md)

**Example expansion**:

**Before**: "Контакт кожа-к-коже (5 мин)"

**After**:
| id | title | category | minAge | maxAge | duration | difficulty | steps | stopIf | fallback |
|----|-------|----------|--------|--------|----------|------------|-------|--------|----------|
| reg_0m_01 | Контакт кожа-к-коже | regulation | 0 | 45 | 5 | 1 | 1. Разденьте ребёнка до подгузника<br>2. Положите на свою грудь<br>3. Накройте тёплым одеялом<br>4. Просто будьте вместе 5 минут | Ребёнок плачет или беспокоится | null |

**Estimated effort**: ~3-4 hours

---

### Task 3: Month 1

**Goal**: Map and refine 30 tasks for 1-month-olds (30-60 days)

**Input** (from Задания.md lines 344-377):
- Examples: "Медленный взгляд в лицо", "Пауза между словами", "Контрастный объект"

**Category distribution target**:
- regulation: 8 tasks
- attention: 8 tasks
- motor: 6 tasks
- cause_effect: 2 tasks
- communication: 4 tasks
- independence: 2 tasks

**Expected Output**: [tasks-month-1.md](flows/sdd-tasks/tasks/tasks-month-1.md)

**Estimated effort**: ~3-4 hours

---

### Task 4: Month 2

**Goal**: Map and refine 30 tasks for 2-month-olds (60-90 days)

**Input** (from Задания.md lines 381-414):
- Examples: "Повтор улыбки", "Диалог звуками", "Медленное движение руки"

**Category distribution target**:
- regulation: 7 tasks
- attention: 7 tasks
- motor: 7 tasks
- cause_effect: 2 tasks
- communication: 5 tasks
- independence: 2 tasks

**Expected Output**: [tasks-month-2.md](flows/sdd-tasks/tasks/tasks-month-2.md)

**Estimated effort**: ~3-4 hours

---

### Task 5: Month 3

**Goal**: Map and refine 30 tasks for 3-month-olds (90-120 days)

**Input** (from Задания.md lines 418-451):
- Examples: "Лёжа на животе", "Опора на предплечья", "Слежение за рукой"

**Category distribution target**:
- regulation: 6 tasks
- attention: 6 tasks
- motor: 8 tasks
- cause_effect: 3 tasks
- communication: 5 tasks
- independence: 2 tasks

**Expected Output**: [tasks-month-3.md](flows/sdd-tasks/tasks/tasks-month-3.md)

**Estimated effort**: ~3-4 hours

---

### Task 6: Month 4

**Goal**: Map and refine 30 tasks for 4-month-olds (120-150 days)

**Input** (from Задания.md lines 455-488):
- Examples: "Захват пальца", "Руки ко рту", "Перекладывание рук"

**Category distribution target**:
- regulation: 5 tasks
- attention: 6 tasks
- motor: 9 tasks
- cause_effect: 3 tasks
- communication: 5 tasks
- independence: 2 tasks

**Expected Output**: [tasks-month-4.md](flows/sdd-tasks/tasks/tasks-month-4.md)

**Estimated effort**: ~3-4 hours

---

### Task 7: Month 6

**Goal**: Map and refine 30 tasks for 6-month-olds (180-210 days)

**Input** (from Задания.md lines 581-612):
- Examples: "Короткое сидение с опорой", "Опора на прямые руки", "Перекладывание предмета"

**Category distribution target**:
- regulation: 5 tasks
- attention: 5 tasks
- motor: 10 tasks
- cause_effect: 3 tasks
- communication: 5 tasks
- independence: 2 tasks

**Expected Output**: [tasks-month-6.md](flows/sdd-tasks/tasks/tasks-month-6.md)

**Estimated effort**: ~3-4 hours

---

### Task 8: Month 7

**Goal**: Map and refine 30 tasks for 7-month-olds (210-240 days)

**Input** (from Задания.md lines 616-647):
- Examples: "Ползание к цели", "Поддержка под живот", "Убрать и вернуть предмет"

**Category distribution target**:
- regulation: 5 tasks
- attention: 5 tasks
- motor: 10 tasks
- cause_effect: 4 tasks
- communication: 4 tasks
- independence: 2 tasks

**Expected Output**: [tasks-month-7.md](flows/sdd-tasks/tasks/tasks-month-7.md)

**Estimated effort**: ~3-4 hours

---

### Task 9: Month 8

**Goal**: Map and refine 30 tasks for 8-month-olds (240-270 days)

**Input** (from Задания.md lines 651-682):
- Examples: "Реакция на имя", "Поиск взглядом", "Прятки с тканью"

**Category distribution target**:
- regulation: 4 tasks
- attention: 6 tasks
- motor: 9 tasks
- cause_effect: 5 tasks
- communication: 4 tasks
- independence: 2 tasks

**Expected Output**: [tasks-month-8.md](flows/sdd-tasks/tasks/tasks-month-8.md)

**Estimated effort**: ~3-4 hours

---

### Task 10: Month 9

**Goal**: Map and refine 30 tasks for 9-month-olds (270-300 days)

**Input** (from Задания.md lines 686-717):
- Examples: "Самостоятельная игра 2–3 мин", "Выбор предмета", "Подражание действию"

**Category distribution target**:
- regulation: 4 tasks
- attention: 5 tasks
- motor: 8 tasks
- cause_effect: 4 tasks
- communication: 5 tasks
- independence: 4 tasks

**Expected Output**: [tasks-month-9.md](flows/sdd-tasks/tasks/tasks-month-9.md)

**Estimated effort**: ~3-4 hours

---

### Task 11: Month 10

**Goal**: Map and refine 30 tasks for 10-month-olds (300-330 days)

**Input** (from Задания.md lines 721-752):
- Examples: "Вставание с опорой", "Опора на одну ногу", "Перенос веса"

**Category distribution target**:
- regulation: 3 tasks
- attention: 5 tasks
- motor: 10 tasks
- cause_effect: 4 tasks
- communication: 4 tasks
- independence: 4 tasks

**Expected Output**: [tasks-month-10.md](flows/sdd-tasks/tasks/tasks-month-10.md)

**Estimated effort**: ~3-4 hours

---

### Task 12: Month 11

**Goal**: Map and refine 30 tasks for 11-month-olds (330-365 days)

**Input** (from Задания.md lines 756-787):
- Examples: "Простые просьбы", "Понимание слов", "Имитация слов"

**Category distribution target**:
- regulation: 3 tasks
- attention: 4 tasks
- motor: 9 tasks
- cause_effect: 4 tasks
- communication: 6 tasks
- independence: 4 tasks

**Expected Output**: [tasks-month-11.md](flows/sdd-tasks/tasks/tasks-month-11.md)

**Estimated effort**: ~3-4 hours

---

### Task 13: Create Fallback Chains

**Goal**: Assign valid fallback references to all difficulty=2 and 3 tasks

**Input**: All 360 tasks with categories and difficulties assigned

**Process**:
1. For each category, sort tasks by age (minAgeDays)
2. For each difficulty=2 or 3 task:
   - Find earlier task in same category with lower difficulty
   - Assign as fallback
3. Validate no circular references

**Expected Output**: Updated all 12 task files with fallback column filled

**Estimated effort**: ~2-3 hours

---

### Task 14: Generate i18n Key List

**Goal**: Document all i18n keys needed for localization phase

**Input**: All 360 tasks with titles, steps, stop conditions

**Process**:
1. For each task, generate keys:
   - `{id}_title`
   - `{id}_step_1`, `{id}_step_2`, etc.
   - `{id}_stop`
2. Create master list

**Expected Output**: [i18n-keys.md](flows/sdd-tasks/i18n-keys.md)

**Estimated effort**: ~1-2 hours

---

### Task 15: Validation

**Goal**: Validate all 360 tasks meet requirements

**Process**:
1. Check all required fields present
2. Validate category values (only 6 allowed)
3. Validate difficulty values (1-3)
4. Check age range logic (maxAge > minAge)
5. Validate fallback references exist
6. Check for circular fallback chains
7. Verify category distribution (~50-70 per category)
8. Verify difficulty distribution (~40% easy, ~40% medium, ~20% hard)

**Expected Output**: [validation-report.md](flows/sdd-tasks/validation-report.md)

**Estimated effort**: ~2-3 hours

---

### Task 16: Create Summary Document

**Goal**: Create executive summary of all 360 tasks

**Process**:
1. Aggregate statistics:
   - Total tasks: 360
   - By category: breakdown
   - By difficulty: breakdown
   - By age group: breakdown
2. Sample tasks from each category
3. Summary of adaptation algorithm

**Expected Output**: [tasks-summary.md](flows/sdd-tasks/tasks-summary.md)

**Estimated effort**: ~1-2 hours

---

## Timeline Estimate

**Total estimated effort**: ~45-55 hours

**Breakdown**:
- Month 5 reference: 3 hours
- Months 0-4 (5 months × 4 hours): 20 hours
- Months 6-11 (6 months × 4 hours): 24 hours
- Fallback chains: 3 hours
- i18n keys: 2 hours
- Validation: 3 hours
- Summary: 2 hours

**Note**: This is content work only - no implementation!

---

## Deliverables Checklist

- [ ] tasks-month-0.md (30 tasks)
- [ ] tasks-month-1.md (30 tasks)
- [ ] tasks-month-2.md (30 tasks)
- [ ] tasks-month-3.md (30 tasks)
- [ ] tasks-month-4.md (30 tasks)
- [ ] tasks-month-5.md (30 tasks) - reference
- [ ] tasks-month-6.md (30 tasks)
- [ ] tasks-month-7.md (30 tasks)
- [ ] tasks-month-8.md (30 tasks)
- [ ] tasks-month-9.md (30 tasks)
- [ ] tasks-month-10.md (30 tasks)
- [ ] tasks-month-11.md (30 tasks)
- [ ] i18n-keys.md (all keys listed)
- [ ] validation-report.md (validation results)
- [ ] tasks-summary.md (executive summary)

**Total**: 360 tasks across 12 files + 3 support documents

---

## Next Steps After Plan Approval

1. Create `flows/sdd-tasks/tasks/` directory
2. Start with Month 5 (reference implementation)
3. Proceed month by month (0-4, then 6-11)
4. Create fallback chains
5. Generate i18n keys list
6. Validate
7. Create summary
8. Get final approval for implementation phase

---

## Notes

- All content will be in Russian
- No JSON files or code will be created in this phase
- Focus is on content refinement and metadata assignment
- Localization to other languages happens in separate sdd-localization flow
- Implementation (creating actual JSON files) happens in separate implementation phase
