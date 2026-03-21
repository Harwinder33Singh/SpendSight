# SpendSight - Progress Tracker

**Project Start**: January 2, 2026  
**Target MVP**: March 4, 2026  
**Last Updated**: March 20, 2026  
**Sprint note**: Original 21-day calendar was planning-only; **codebase** now includes Transactions, Dashboard, Budgets, and Settings flows.

---

## 📊 Overall Progress

```
Phase 1: Foundation          [████████████████████] 100% ✅
Phase 2: Core Functionality  [█████████████████░░░]  88% 🚧
Phase 3: Advanced Features   [░░░░░░░░░░░░░░░░░░░░]   0% 📅
```

**Overall Project**: ~80% toward MVP UI (tests & hardening remain)

---

## 🎯 Weekly Progress

### Week 1: Foundation & Manual Entry (Feb 11-17, 2026)
**Goal**: Manual Entry Form Complete  
**Status**: ✅ Complete (extended into Week 2)

| Day | Date | Tasks | Status | Hours | Notes |
|-----|------|-------|--------|-------|-------|
| 1 | Feb 11 | Project planning & documentation | ✅ | 3 | Created plan, README, TODO, ChangeLog, Contributing |
| 2 | Feb 12 | Core Data extensions + category seeding integration | ✅ | 5 | Completed all 5 extension files, seeder integration, debug tools |
| 3 | Feb 13 | Core Data follow-ups + Manual Entry kickoff | ✅ | - | Fix routing/helper issues, start ManualEntryView |
| 4 | Feb 14 | CategorySeeder + Default categories | ✅ | - | Completed early on Feb 12 |
| 5-7 | Feb 15-17 | Manual Entry form + Onboarding | ✅ | - | Manual entry form, onboarding flow, app coordinator |

**Week 1 Progress**: ████████ 100%

---

### Week 2: Transactions & Dashboard (Feb 18-24, 2026)
**Goal**: View and analyze transactions  
**Status**: ✅ Delivered in Xcode (see `TransactionsView`, `DashboardView`); calendar week was planning-only

| Milestone | Status | Notes |
|-----------|--------|--------|
| Transactions list, search, filters, edit/delete | ✅ | `TransactionsView` + `TransactionsViewModel` + `TransactionComponents` |
| Dashboard summaries + Swift Charts | ✅ | `DashboardView` + `DashboardViewModel` + chart components |
| Polish / perf / tests | 🚧 | Ongoing |

**Week 2 Progress**: ████████ 100% (feature scope); polish continues

---

### Week 3: Budgets & Settings (Feb 25 - Mar 4, 2026)
**Goal**: Complete MVP  
**Status**: 📅 Not Started

| Day | Date | Tasks | Status | Hours | Notes |
|-----|------|-------|--------|-------|-------|
| 15 | Feb 25 | Budget overview screen | 📅 | - | List categories with budgets |
| 16 | Feb 26 | Budget setting UI per category | 📅 | - | Edit budget amounts |
| 17 | Feb 27 | Budget progress & notifications | 📅 | - | Progress bars and alerts |
| 18 | Feb 28 | Budget testing | 📅 | - | Comprehensive budget testing |
| 19 | Mar 1 | Settings screen & account management | 📅 | - | Build settings UI |
| 20 | Mar 2 | Settings completion | 📅 | - | Export, preferences, polish |
| 21 | Mar 3 | Final testing & bug fixes | 📅 | - | End-to-end testing |
| - | Mar 4 | **MVP LAUNCH** 🎉 | 📅 | - | Celebrate! |

**Week 3 Progress**: ░░░░░░░░ 0%

---

## 📋 Task Completion Tracker

### 🔴 Critical Path Tasks

#### Task 1: Core Data Extensions ✅
**Duration**: 2 days | **Status**: Completed Early (Day 2) | **Priority**: HIGHEST

- [x] Transaction+Extensions.swift (completed)
  - [x] Convenience initializer
  - [x] Display properties
  - [x] Fetch requests
  - [x] Validation methods
- [x] Category+Extensions.swift (completed)
  - [x] Convenience initializer
  - [x] Color conversion
  - [x] Fetch requests
  - [x] Sort descriptors/helpers
  - [x] Validation methods
- [x] Account+Extensions.swift (completed)
  - [x] Convenience initializer
  - [x] Display properties
  - [x] Validation
  - [x] Fetch and helper methods
- [x] Income+Extensions.swift (completed)
  - [x] Convenience initializer
  - [x] Display properties
  - [x] Fetch requests
  - [x] Validation
- [x] SavingsPlan+Extensions.swift (completed)
  - [x] Convenience initializer
  - [x] Progress calculations
  - [x] Fetch requests
  - [x] Validation
- [x] UserProfile+Extensions.swift (completed)
  - [x] Profile / onboarding-related helpers

**Progress**: ██████████ 6/6 extension files (100%)

**Next Steps**:
- Maintain extensions as the model evolves (e.g. new `UserProfile` fields)

---

#### Task 2: Default Categories ✅
**Duration**: 1 day | **Status**: Completed Early (Day 2) | **Priority**: HIGH

- [x] `CategorySeeder.swift` and UserDefaults seeding flag
- [x] Onboarding presents selectable default category templates (`OnboardingViewModel.defaultCategories`)
- [x] Selected categories persisted to Core Data at end of onboarding
- [ ] Broader production QA (edge cases, logout/re-onboard)

**Progress**: ██████████ Onboarding + seeder utilities integrated

**Note**: The commented `CategorySeeder.seedIfNeeded` block in `SpendSightApp` is **not** the active first-run path.

---

#### Task 3: Manual Entry Form ✅
**Duration**: 3 days | **Status**: Complete | **Priority**: CRITICAL

- [x] Form state management
- [x] Amount input field
- [x] Date picker
- [x] Category picker (grid)
- [x] Account selector
- [x] Merchant/title field
- [x] Payment method picker
- [x] Notes field
- [x] Recurring toggle
- [x] Save button with validation
- [x] Success feedback
- [x] Form reset functionality

**Progress**: ████████████ 12/12 items (100%)

**Completed**: Feb 15-17+ (Days 5-7, extended)

---

#### Task 4: Transactions List ✅
**Duration**: — | **Status**: Complete in repo

- [x] Fetch transactions (`@FetchRequest`)
- [x] Group by date (section headers)
- [x] Transaction row + detail
- [x] Swipe delete (with confirmation) / swipe edit (sheet)
- [x] Filter sheet + search
- [x] Empty state + `refreshable`

**Progress**: 9/9 core items

---

#### Task 5: Dashboard View ✅
**Duration**: — | **Status**: Complete (core scope)

- [x] Summary cards (today / week / month / daily avg)
- [x] Top categories chart + 30-day trend (Swift Charts)
- [x] Floating add → Manual Entry sheet

**Follow-ups**: optional recent list strip, budget overrun banner, chart interactions

---

### 🟡 Secondary Tasks

#### Task 6: Budget Management 🚧
**Status**: Major UI shipped (`BudgetsView`, `AddBudgetView`, `BudgetDetailView`) | **Progress**: ~85%  
**Remaining**: notifications, deeper test coverage

#### Task 7: Settings View 🚧
**Status**: Substantial (`SettingsView` + category/account sheets) | **Progress**: ~80%  
**Remaining**: verify export/backup flows, global currency wiring

---

## 📈 Velocity & Estimates

### Completed Work
- **Foundation**: Core Data (6 entities), extensions, onboarding, coordinator, root tabs ✅
- **Features**: Manual entry, transactions, dashboard, budgets UI, settings management ✅

### Remaining Work
- Automated tests, performance tuning, export/backup verification, Phase 3 features

### Risk Assessment
- ✅ **UI scope**: Main flows exist in Xcode
- ⚠️ **Quality**: Needs test coverage and device-matrix testing
- ⚠️ **Data lifecycle**: Review `AppCoordinator.logout` batch deletes vs all entity types

---

## 🎯 Milestones

| Milestone | Target Date | Status | Completion |
|-----------|-------------|--------|------------|
| Project Plan Complete | Feb 11 | ✅ | 100% |
| Core Data Extensions | Feb 13 | ✅ | 100% |
| Manual Entry Working | Feb 17 | ✅ | 100% |
| Category setup (onboarding + seeder utilities) | Feb 14 | ✅ | 100% |
| Transactions List | Feb 21 | ✅ | 100% |
| Dashboard Analytics | Feb 24 | ✅ | 100% |
| Budget Management | Feb 28 | 🚧 | ~85% |
| Settings Complete | Mar 2 | 🚧 | ~80% |
| **MVP Launch** | **Mar 4** | 🚧 | **~80%** |

---

## 🏆 Achievements Unlocked

- ✅ **Architect**: Designed comprehensive data model
- ✅ **Planner**: Created detailed 3-week development plan
- ✅ **Documenter**: Wrote complete project documentation
- ✅ **Debugger**: Identified validation bugs early

### Next Achievement
- 🎯 **Quality**: XCTest coverage for view models and critical Core Data paths

---

## 📝 Daily Log

### 2026-02-12 (Day 2) 🚧
**Focus**: Core Data Extensions + Category Seeding Integration

**Completed**:
- ✅ Completed Transaction+Extensions.swift
  - Convenience initializer, display properties, fetch request builders, validation
- ✅ Completed Category+Extensions.swift
  - Convenience initializer, color conversion helpers, fetch/sort helpers, validation
- ✅ Completed Account+Extensions.swift
  - Convenience initializer, display properties, fetch/sort helpers, validation, balance helpers
- ✅ Completed Income+Extensions.swift
  - Convenience initializer, display properties, fetch/sort helpers, validation
- ✅ Completed SavingsPlan+Extensions.swift
  - Convenience initializer, progress helpers, fetch/sort helpers, validation
- ✅ Implemented CategorySeeder.swift
  - Added 10 default categories (name, color, icon, optional budget)
  - Added one-time seeding flag with UserDefaults (`hasSeededCategories`)
  - Added `seedIfNeeded`, `resetSeedingFlag`, and `needsSeeding`
- ✅ Integrated category seeding at app launch (`SpendSightApp`)
- ✅ Added CategorySeeder debug/test helpers and debug view
  - Print categories
  - Delete categories
  - Full reset and re-seed actions

**Review Findings (Static)** (resolved in quick fixes):
1. ~~Manual Entry tab opened CategorySeederDebugView~~ → RootTabView correctly shows `ManualEntryView`.
2. ~~`Category.createDefaultCategories` had 9 defaults, missing "Housing"~~ → Housing added to helper; `sortByBudgetDescending` renamed from `sortByNameDescendingMonthlyBudget`.

**Blockers**: None

**Hours Worked**: 5 hours

**Notes**: 
- Category seeding work moved ahead of schedule (originally Day 4)
- Debug utilities are in place to verify and reset seeding behavior quickly
- Core Data extension implementation is complete; next is feature integration

**Tomorrow's Plan**:
1. ~~Fix Manual Entry tab routing~~ (already correct in codebase)
2. ~~Align default category helper list with seeder list~~ (Housing added in quick fixes)
3. Begin Manual Entry form implementation (or continue polish)

---

### 2026-02-11 (Day 1) ✅
**Focus**: Project Planning & Documentation

**Completed**:
- ✅ Comprehensive project plan PDF
- ✅ README.md with full documentation
- ✅ TODO.md with detailed task breakdown
- ✅ ChangeLog.md for version tracking
- ✅ Contributing.md with coding standards
- ✅ Progress Tracker.md (this file)

**Blockers**: None

**Hours Worked**: 3 hours

**Notes**: 
- Solid foundation established
- Clear roadmap for 3 weeks
- Ready to start coding

**Next Day's Plan**:
1. Create Core Data extensions folder
2. Start Transaction+Extensions.swift
3. Start Category+Extensions.swift
4. Write and test display properties

---

### 2026-03-20 ✅
**Focus**: Documentation aligned with repository

**Completed**:
- ✅ README / TODO / ChangeLog / Contributing / this file updated for **actual** paths (`Models/`, `Views/`, etc.)
- ✅ Documented **six** Core Data entities including `UserProfile`
- ✅ Recorded shipped **Transactions**, **Dashboard**, **Budgets**, **Settings** surfaces

**Next**: Tests, logout/data wipe audit, LICENSE if open-sourcing

---

### 2026-02-18 (Day 8) 🚧
**Focus**: Week 2 kickoff – Transactions list & documentation

**Completed**:
- ✅ Onboarding flow in place (OnboardingView, OnboardingViewModel, OnboardingStepViews, AddAccountSheet)
- ✅ AppCoordinator for app state (loading → onboarding → main / failed)
- ✅ Core Data model updates (TrackSpendture.xcdatamodeld)

**Notes**: Subsequent development delivered full Transactions and Dashboard (see Week 2 table above).

---

### 2026-02-13 (Day 3) ✅
**Focus**: Core Data Extensions - Part 2

**Planned**:
- [x] ~~Fix tab routing mismatch~~ (already correct)
- [x] ~~Fix default category helper mismatch~~ (quick fixes applied)
- [x] Start ManualEntryView form state + layout (or polish)
- [x] Add validation and save flow skeleton

**Completed**: Manual Entry and onboarding work continued through Feb 17.

**Blockers**: None

**Notes**: —

---

## 🐛 Bugs & Issues

### Active Issues
_None._

### Resolved Issues
- Transaction validation logic bug (resolved)
- Category sort descriptor typo/mismatch (resolved)
- Manual Entry tab routing: RootTabView already shows `ManualEntryView` (no change needed)
- Default category mismatch: Added "Housing" to `Category.createDefaultCategories`; renamed `sortByNameDescendingMonthlyBudget` → `sortByBudgetDescending`

---

## 💡 Ideas & Improvements

### Discovered During Development
- Consider creating reusable validation helper functions
- Could extract formatting logic into separate utility class
- Might want to add more comprehensive Core Data fetch request helpers

---

## ⏱️ Time Tracking

_Table below reflects early sprint estimates only; it was not updated after major UI work shipped._

| Week | Planned Hours | Actual Hours | Variance |
|------|---------------|--------------|----------|
| Week 1 | 30 | 8 | -22 |
| Week 2 | 30 | — | — |
| Week 3 | 30 | — | — |
| **Total** | **90** | **—** | **—** |

---

## 🎓 Lessons Learned

### Week 1
- **Day 1**: Good documentation saves time later
- **Day 2**: Shipping seeding utilities early de-risked onboarding and manual entry

---

## 📊 Sprint Burndown

_Original 21-day task burndown; **feature work outpaced** this calendar. Use GitHub milestones or TODO.md for current work._

```
(Planning artifact — not recalculated for March 2026 codebase state.)
```

---

**Remember**: Update this tracker daily to stay on track and motivated! 🚀

**Next Update**: As milestones land (tests, export verification, Phase 3 kickoff)
