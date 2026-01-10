# Requirements: Task Content Refinement

**Version**: 1.1
**Date**: 2026-01-09
**Status**: Draft

---

## Problem Statement

The DailyBabyCoach MVP has core infrastructure (data models, adaptive engine, screens) but needs **refined task content** to deliver value. Current state:

- **360 tasks exist** in `Задания.md` (Russian, mixed detail levels)
- Some tasks are detailed (first 20 for month 5), others are minimal bullet points
- Tasks need consistent structure and metadata
- Unclear mapping to the 6 skill directions
- Missing adaptation metadata (difficulty, fallbacks)

**Impact**: Without refined, consistent task content, the app cannot provide clear, safe, personalized daily activities.

---

## Scope Clarification

### ✅ IN SCOPE (Content Work Only)
- Refine and structure all 360 tasks **in Russian**
- Add metadata for adaptive selection (difficulty, fallbacks, skill tags)
- Document task structure and adaptation algorithms
- Map tasks to 6 skill directions

### ❌ OUT OF SCOPE
- **No code implementation** (this is content/design work only)
- **No localization** (will be handled separately in sdd-localization)
- **No Flutter/JSON file creation** (implementation is separate)
- **No i18n keys** (handled in sdd-localization)

---

## User Stories

### US-1: Content Refinement
**As a** content designer
**I want** all 360 tasks reviewed, refined, and validated **in Russian**
**So that** parents receive safe, clear, age-appropriate activities

**Acceptance Criteria**:
- [ ] All tasks have consistent structure (название, длительность, шаги, предупреждения, цель)
- [ ] Tasks are validated for safety (no choking hazards, developmentally appropriate)
- [ ] Tasks clearly state when to stop (baby signals)
- [ ] Language is simple, actionable, jargon-free (Russian)
- [ ] Tasks are categorized by skill direction

### US-2: Content Structure Documentation
**As a** developer
**I want** all tasks following the exact structure defined in sdd-mvp
**So that** implementation can directly use this content

**Acceptance Criteria**:
- [ ] All tasks follow the exact structure from sdd-mvp/02-specifications.md:
  - `id` (String): e.g., "attn_5m_01" (skill_month_number format)
  - `minAgeDays` (int): minimum age in days
  - `maxAgeDays` (int): maximum age in days
  - `duration` (int): minutes
  - `category` (String): one of 6 skills (regulation/attention/motor/cause_effect/communication/independence)
  - `difficulty` (int): 1-3 scale
  - `titleKey` (String): i18n key for title (e.g., "attn_5m_01_title")
  - `stepsKeys` (List<String>): i18n keys for steps (e.g., ["attn_5m_01_step_1", ...])
  - `stopIfKey` (String): i18n key for stop condition
  - `fallback` (String): task ID to fall back to if too hard
- [ ] Example tasks provided showing complete structure
- [ ] Content organized in readable format (markdown tables)

### US-3: Skill Mapping
**As a** product owner
**I want** tasks mapped to the 6 skill directions
**So that** the adaptive engine can select balanced daily activities

**Acceptance Criteria**:
- [ ] Each task's `category` field set to one of 6 exact values:
  - `regulation` - 🧠 Регуляция (саморегуляция, успокоение)
  - `attention` - 👀 Внимание (фокус, концентрация)
  - `motor` - ✋ Моторика (крупная + мелкая)
  - `cause_effect` - 🔁 Причина-Следствие
  - `communication` - 💬 Коммуникация (звуки, жесты)
  - `independence` - 🧩 Самостоятельность
- [ ] Each task has clear rationale for its category assignment
- [ ] Distribution across categories is roughly balanced

### US-4: Adaptive Metadata
**As a** developer
**I want** task metadata that enables adaptive selection
**So that** the app can personalize based on feedback

**Acceptance Criteria**:
- [ ] Each task has correct metadata per sdd-mvp structure:
  - `minAgeDays` / `maxAgeDays` - flexible age ranges (e.g., 120-210 days spans multiple months)
  - `difficulty` - 1 (easy), 2 (medium), 3 (hard) within each skill category
  - `fallback` - task ID to use if this task is too hard (usually earlier/easier task in same skill)
  - `duration` - realistic time in minutes (3-10 min typical)
- [ ] Age ranges allow flexibility (tasks can span multiple months)
- [ ] Each difficulty=2 or 3 task has a valid fallback task
- [ ] Fallback chains don't create circular references

### US-5: Adaptation Algorithm Documentation
**As a** developer
**I want** clear documentation of task selection and adaptation logic
**So that** I can implement the adaptive engine later

**Acceptance Criteria**:
- [ ] Selection algorithm documented (how to pick 2-3 daily tasks)
- [ ] Adaptation rules specified (when to increase/decrease difficulty)
- [ ] Fallback logic documented (how to handle "task too hard")
- [ ] Skill rotation strategy defined (how to balance across 6 directions)

---

## Constraints

### Must Have
- **Safety first**: All tasks must be safe for unsupervised parent-baby interaction
- **No equipment required**: Tasks use only household items or nothing
- **Screen-free for baby**: No videos, apps shown to baby (text-only MVP)
- **Interruptible**: Tasks can stop any time based on baby signals
- **Russian language**: All content in Russian (localization handled separately)
- **Skill-based, not age-based**: Tasks organized by 6 skill directions (Regulation, Attention, Motor, Cause-Effect, Communication, Independence)
- **Adaptive-friendly metadata**: Each task has difficulty level, fallback references, age ranges (min/max days)
- **Content-only deliverable**: No code, no JSON files - only refined content and documentation

### Should Have
- **Consistent format**: All 360 tasks follow same structure
- **Balanced coverage**: Tasks span all 6 skill directions roughly equally
- **Progressive difficulty**: Tasks within each month vary in complexity

### Won't Have (in this scope)
- **Video content**: Tasks are text-only for MVP
- **AI-generated content**: Use existing 360 tasks, refine but don't generate new
- **Complex dependency trees**: Keep prerequisites simple
- **Code implementation**: No Flutter code, no JSON files creation
- **Localization**: No translation to EN/TH/ZH/HI (separate flow: sdd-localization)
- **Database setup**: No Firebase, no data structures - content only

---

## Open Questions (RESOLVED)

1. **Skill Mapping**: ✅ Trust existing categorization (no external validation needed)
2. **Language Scope**: ✅ Russian only (localization handled in separate sdd-localization flow)
3. **Task Granularity**: ✅ Keep minimal tasks short - they serve as "regulation/stability" activities (per concept doc)
4. **Feedback Loop**: ✅ Use simple rule-based adaptation:
   - 👍 Easy (2x in row) → difficulty +1
   - 😣 Hard / ⛔ Failed → fallback task or difficulty -1
   - Track per-skill progress, not overall development scores
5. **Deliverable Format**: ✅ Content only - refined tasks in markdown/readable format, with algorithm documentation. No code implementation.

---

## Success Criteria

This work is complete when:
1. ✅ All 360 tasks are refined, structured, and validated (in Russian)
2. ✅ Task structure and metadata requirements are documented
3. ✅ Tasks are mapped to 6 skill directions with difficulty/fallback metadata
4. ✅ Adaptation algorithm is documented clearly
5. ✅ Content is organized in readable format (markdown) ready for implementation phase
6. ✅ Developer can understand what needs to be implemented based on this documentation

---

## Non-Goals (Explicit)

- **Not creating new tasks**: Using existing 360 tasks as base, only refining them
- **Not implementing code**: This is content refinement + documentation work only
- **Not translating**: Localization to other languages happens in sdd-localization
- **Not building data structures**: No JSON files, no database schemas - content only
- **Not doing user research**: Trusting existing product concept and task design
