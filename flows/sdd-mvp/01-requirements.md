# Requirements: Daily Baby Coach MVP

**Version**: 1.0
**Date**: 2026-01-08
**Status**: Draft (awaiting approval)

---

## Problem Statement

Parents of infants (0-12 months) face several challenges:
- **Information overload**: Too many generic articles and courses without clear daily actions
- **Uncertainty**: Not knowing what specific activities to do each day to support development
- **Inconsistency**: Lack of structured, daily engagement patterns
- **Adaptation gap**: Existing apps provide static content that doesn't adjust to individual baby's progress
- **Time constraints**: Need quick, actionable activities (5-20 minutes)

Existing solutions are either:
- Sleep/feeding trackers without developmental guidance
- Static lists of exercises without personalization
- General educational content without daily structure
- No feedback loop to adapt to baby's actual responses

---

## Vision

**Daily Baby Coach** provides parents with a simple, daily answer to "What should I do with my baby today?"

Every day, parents receive 2-3 personalized, age-appropriate activities (5-20 minutes each) that adapt based on their baby's responses and progress.

---

## User Stories

### Primary User: Parent with 0-12 month old infant

#### Story 1: Daily Guidance
**As a** parent with a 5-month-old
**I want** to see 2-3 specific activities to do today
**So that** I feel confident I'm supporting my baby's development without guessing

**Acceptance Criteria**:
- [ ] Single "Today" screen shows daily activities on app open
- [ ] Activities are age-appropriate (based on baby's age in days)
- [ ] Each activity shows duration (5-20 minutes)
- [ ] Activities span different developmental areas (attention, motor, communication, etc.)

#### Story 2: Easy Execution
**As a** busy parent
**I want** simple, text-based instructions I can follow with one hand
**So that** I can do activities while holding or managing my baby

**Acceptance Criteria**:
- [ ] Each activity has 3-5 clear, numbered steps
- [ ] Text-only format (no video/audio required in MVP)
- [ ] Built-in timer to track activity duration
- [ ] "Stop if" guidance for when to end early

#### Story 3: Adaptive Learning
**As a** parent tracking my baby's responses
**I want** the app to adjust activities based on feedback
**So that** activities stay appropriately challenging, not too hard or too easy

**Acceptance Criteria**:
- [ ] After each activity, simple feedback: easy/normal/hard/didn't work
- [ ] If activity is too hard 2x, next day offers easier alternative
- [ ] If activity is easy 2x in a row, difficulty increases
- [ ] Activities from earlier months can return on "difficult days"

#### Story 4: Sleep Training Support
**As a** sleep-deprived parent
**I want** gentle, incremental sleep training guidance
**So that** I can help my baby develop better sleep habits without harsh methods

**Acceptance Criteria**:
- [ ] Separate sleep-focused activities (calm preparation, self-soothing steps)
- [ ] Incremental approach (e.g., day 1: reduce rocking amplitude, day 2: put down drowsy)
- [ ] Evening-appropriate UI (darker, calmer tone)
- [ ] No "cry-it-out" methods

#### Story 5: Start at Any Age
**As a** parent discovering the app when my baby is already 7 months old
**I want** to start immediately with age-appropriate content
**So that** I don't have to "catch up" on months 0-6

**Acceptance Criteria**:
- [ ] Onboarding asks current age + basic capabilities
- [ ] App selects starting difficulty based on responses
- [ ] Earlier month activities available as "easier alternatives" if needed
- [ ] No penalty or "missed content" messaging

#### Story 6: Multilingual Support
**As a** non-English speaking parent
**I want** content in my language (RU/TH/ZH)
**So that** I can understand and follow instructions clearly

**Acceptance Criteria**:
- [ ] UI and task content support EN, RU, TH, ZH
- [ ] Locale auto-detected on first launch
- [ ] Content keys structured for easy translation (i18n pattern)

---

## Developmental Skill Areas (6 Core)

Activities are categorized into these skill directions:

1. **Regulation** - Calming, self-soothing, emotional regulation
2. **Attention** - Visual tracking, focus, engagement
3. **Motor** - Gross and fine motor skills, body control
4. **Cause-Effect** - Understanding actions lead to results
5. **Communication** - Sounds, gestures, early language
6. **Independence** - Self-play, problem-solving, autonomy

---

## Content Scope (MVP)

### Task Library
- **360 total activities**: 30 per month × 12 months (0-11 months)
- Each task includes:
  - ID, age range (min/max days), duration
  - Skill category, difficulty level
  - Title key, step keys (for i18n)
  - "Stop if" safety guidance
  - Fallback task ID (for easier alternative)

### Task Structure Example (JSON)
```json
{
  "id": "attn_5m_01",
  "minAgeDays": 150,
  "maxAgeDays": 180,
  "duration": 5,
  "category": "attention",
  "difficulty": 1,
  "titleKey": "attn_5m_01_title",
  "stepsKeys": ["attn_5m_01_step_1", "attn_5m_01_step_2", ...],
  "stopIfKey": "attn_5m_01_stop",
  "fallback": "attn_3m_02"
}
```

---

## Adaptive Logic (Rule-Based, No AI/ML in MVP)

### Feedback Collection
After each activity:
- 👍 Easy → score +1
- 😐 Normal → score 0
- 😣 Hard → score -1
- ⛔ Didn't work → score -2

### Adaptation Rules
1. **If last 2 results = "Easy"** → increase difficulty (+1)
2. **If last result ≤ -1** → use fallback task or decrease difficulty
3. **If skill has 2+ "Hard" streak** → prioritize that skill with easier tasks
4. **If skill unused 3+ days** → rotate it back in
5. **"Tough day" mode**: User can trigger simplified plan (fewer, calmer tasks)

### Skill Scoring
Each skill tracks:
- `score`: sum of last 7 results (range: -14 to +7)
- `streak_easy`: consecutive easy completions
- `streak_hard`: consecutive hard completions
- `last_day_used`: for rotation logic

---

## User Flows

### Flow A: First Launch (Onboarding - 60-90 seconds)
1. Splash screen
2. Value proposition screen ("Daily activities for your baby")
3. Baby's age in months (or birthdate)
4. 3-5 quick questions:
   - How does baby fall asleep? (rocking/feeding/self)
   - What can baby do? (checkboxes: rolls over, sits, etc.)
   - Today's mood? (calm/active/fussy)
5. Permission for notifications
6. → Straight to "Today" screen

**No registration required before value delivery**

### Flow B: Daily Loop (Core Habit)
1. Push notification: "Time for today's activities"
2. Open app → "Today" screen
3. Select first activity card
4. Read instructions (title, steps, "stop if", duration)
5. Tap "Start Timer"
6. Complete activity
7. Feedback: 👍😐😣⛔ + optional comment
8. → Next activity or "Finish Day"

### Flow C: Sleep Training
1. "Today" screen includes sleep-specific activity
2. Evening-timed push notification
3. Activity shows incremental step (e.g., "Reduce rocking time by 30 seconds")
4. Next morning: "How did sleep go?" feedback
5. Next sleep activity adapts based on feedback

### Flow D: Tough Day
1. "Today" screen shows "Having a tough day?" button
2. Tap → adjusted plan with:
   - Fewer activities (1-2 instead of 3)
   - Focus on calming/regulation skills
   - Lower difficulty tasks
3. No penalty to progression

---

## Screen Structure

### Primary Screens (MVP)
1. **Today Screen** (Home)
   - Date + baby's age (e.g., "5 months 12 days")
   - 2-3 activity cards with color-coded categories
   - Duration badges
   - "Tough day?" toggle
   - Progress indicator (completed/total for today)

2. **Task Screen**
   - Activity title
   - Duration badge
   - Numbered steps (3-5 steps)
   - "Stop if" guidance
   - "Start Timer" CTA

3. **Timer Screen**
   - Countdown timer
   - "Finish Early" button
   - Ambient reminder (1-2 mid-activity prompts)

4. **Feedback Screen**
   - "How did it go?" with 4 emoji options
   - Optional: "How many minutes?"
   - Optional: Free text comment (short)
   - "Done" CTA

5. **Baby Profile** (Settings)
   - Birthdate / age
   - Current capabilities (checkboxes)
   - Notification preferences

### Navigation
- **No tabs, no complex menus**
- "Today" is the anchor
- Profile accessible via top-right icon
- Back navigation for secondary screens

---

## Constraints

### MVP Scope
- **No video/audio content** (text-only instructions)
- **No social features** (no sharing, forums, comparisons)
- **No AI/ML models** (rule-based adaptation only)
- **No backend/server** in first version (local JSON + device storage)
- **No integration** with other trackers or wearables
- **No expert consultations** or paid human support
- **No medical advice** or developmental assessments

### Platform
- **iOS first** (App Store submission MVP)
- Android deferred to post-MVP
- Web version not planned

### Content
- **Ages 0-12 months only** (no toddlers/preschoolers in MVP)
- **4 languages**: EN, RU, TH, ZH
- **No regional variations** of content (single global content set per language)

### UX Constraints
- **Offline-first**: Core functionality works without internet
- **One-handed usable**: Large tap targets, minimal scrolling
- **Night-mode ready**: Dark theme for evening sleep activities
- **No "development scores"**: No language suggesting baby is behind/ahead

---

## Non-Goals (Explicit Out of Scope)

- ❌ Comprehensive baby tracker (sleep, feeding, diapers)
- ❌ Milestone assessment or developmental testing
- ❌ Medical advice or diagnosis
- ❌ Comparison with other babies ("norms", percentiles)
- ❌ Gamification with points/badges for parents
- ❌ Parent social network or community
- ❌ E-commerce (selling products)
- ❌ Complex ML personalization (future phase)
- ❌ Video-based content (future enhancement)
- ❌ Multiple child profiles in MVP

---

## Monetization (Future, Not MVP)

### Free Tier
- 1 activity per day
- Basic tips

### Paid ($5-10/month)
- Full daily plan (2-3 activities)
- Sleep training program
- Progress history
- All 4 languages

### Upsells (Post-MVP)
- Personalized sleep plan (PDF + interactive)
- Expert consultation partnerships

**MVP decision**: Launch with free tier only, validate engagement before paywall

---

## Success Metrics (Post-Launch)

### Engagement
- **Daily Active Users (DAU)**: % of users opening app daily
- **Activity Completion Rate**: % of activities marked complete
- **Session Duration**: Time spent per session
- **Retention**: D7, D30 retention rates

### Product-Market Fit
- **Feedback Quality**: Ratio of positive (easy/normal) vs negative (hard/didn't work)
- **"Tough Day" Usage**: Frequency of adjusted plans requested
- **Sleep Activity Engagement**: Completion rate for sleep training tasks

### Technical
- **Crash-Free Rate**: >99%
- **Offline Usage**: % of sessions without network

---

## Decisions Made

### Product Decisions (User Approved)
1. **Language priority**: EN first, others follow
2. **Content authoring**: Decisions delegated to implementation team
3. **Notification timing**: Decisions delegated to implementation team
4. **Baby profile updates**: Decisions delegated to implementation team
5. **Feedback fatigue**: Decisions delegated to implementation team

### Technical Decisions (For Specs Phase)
- Local storage: TBD in specifications
- State management: TBD in specifications
- Content updates: TBD in specifications
- Analytics: TBD in specifications

---

## Dependencies

### Design Assets Needed
- Activity category icons (6 skill types)
- Empty state illustrations
- Onboarding screens
- Feedback emoji set

### Content Production
- 360 activities written and translated
- Localization QA for RU/TH/ZH
- Pediatric review (optional but recommended)

### Third-Party Services
- Push notifications (Firebase Cloud Messaging or APNs direct)
- Analytics (Firebase or equivalent)
- Crash reporting (Firebase Crashlytics or Sentry)

---

## Timeline Estimate (Not Binding)

**Phase 1 - Requirements** (current): 1 week
**Phase 2 - Specifications**: 1-2 weeks
**Phase 3 - Plan**: 1 week
**Phase 4 - Implementation**: 6-8 weeks
**Phase 5 - Content Production**: Parallel with implementation
**Phase 6 - Testing & QA**: 2 weeks
**Phase 7 - App Store Submission**: 1-2 weeks review

**Total MVP**: ~12-16 weeks from requirements approval

---

## Next Steps

1. **Review these requirements** for completeness and accuracy
2. **Answer open questions** to clarify ambiguities
3. **Approve or request changes** before moving to specifications
4. Once approved, proceed to **specifications phase** (technical design, data models, architecture)

---

**Status**: ✅ APPROVED (2026-01-08) - Proceeding to specifications phase.
