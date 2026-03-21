# Changelog
All notable changes to SpendSight will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Documentation & codebase alignment — 2026-03-20

##### Changed
- README, TODO, Progress Tracker, Contributing, and this changelog updated to match the **current** repository:
  - Folder layout: `Models/`, `Views/`, `ViewModels/`, `Managers/` (not legacy `Core/` + `Features/` paths).
  - Core Data model documents **six** entities: `Account`, `Category`, `Income`, `SavingsPlan`, `Transaction`, `UserProfile`.
  - `PersistenceController` exposes `loadError`; `SpendSightApp` uses `AppCoordinator` with `.failed` for store load failures.
  - Category setup is driven primarily by **onboarding** (`OnboardingViewModel`); `CategorySeeder.seedIfNeeded` in `SpendSightApp` remains commented—seeding flags/helpers still used from onboarding completion.
- README links fixed to actual filenames: `Contributing.md`, `ChangeLog.md`, `Progress Tracker.md` (URL-encoded link where needed).

##### Added (implementation summary captured in docs)
- **Transactions**: `TransactionsView` + `TransactionsViewModel` — grouped list, `.searchable`, filter sheet, swipe edit/delete, `refreshable`, empty states.
- **Dashboard**: `DashboardView` + `DashboardViewModel` — summary cards, `CategorySpendingChart`, `SpendingTrendChart`, floating add → `ManualEntryView`.
- **Budgets** / **Settings**: substantive SwiftUI flows beyond placeholders (e.g. `BudgetsView`, `AddBudgetView`, `BudgetDetailView`; settings sheets for categories, accounts, backup UI, etc.).

---

### Week 2 (Feb 18-24, 2026) - Superseded by later implementation

#### [0.3.0] - 2026-02-18
**Day 8 of 21 - Documentation & Week 2 Kickoff**

##### Added
- Onboarding flow: `OnboardingView`, `OnboardingViewModel`, `OnboardingStepViews`, `AddAccountSheet`
- `AppCoordinator` for app state (loading → onboarding → main)
- First-launch onboarding before main app content

##### Changed
- `SpendSightApp`: uses `AppCoordinator`; shows loading → onboarding → `RootTabView` with category seeding
- All .md docs updated to Feb 18, 2026 (TODO, Progress Tracker, README, ChangeLog, Contributing)
- Progress Tracker: Week 2 Day 8, Task 3 (Manual Entry) marked complete, Week 1 complete
- Core Data model: `TrackSpendture.xcdatamodeld` updated

##### In Progress
- Transactions list view (fetch, display, row component)
- Filtering and search (Week 2)

##### Planned
- Dashboard layout and charts (Week 2)
- Budget management, Settings (Week 3)

---

### Week 1 (Feb 11-17, 2026) - Complete

#### [0.2.0] - 2026-02-12
**Day 2 of 21 - Core Data Extensions + Category Seeding**

##### Added
- `CategorySeeder` utility with one-time seeding guard via UserDefaults (`hasSeededCategories`)
- 10 default categories with icon, color, and optional monthly budgets
- Category seeding debug/testing helpers (`print`, `delete`, `full reset`, `status`)
- `CategorySeederDebugView` for manual verification of seeding behavior

##### Changed
- App launch flow now triggers `CategorySeeder.seedIfNeeded(...)` from `SpendSightApp`
- `RootTabView` temporarily points the "Manual Entry" tab to `CategorySeederDebugView` for validation

##### In Progress
- Core Data extensions for Transaction entity
- Core Data extensions for Category entity

##### Identified Issues
- Transaction+Extensions.swift validation logic needs fixing (lines 181-194)
- Category+Extensions.swift has sort descriptor typo and mismatch

##### Planned for This Week
- Complete all 5 Core Data extensions (Transaction, Category, Account, Income, SavingsPlan)
- Create CategorySeeder for default categories (Feb 14)
- Build Manual Entry form UI (Feb 15-17)

---

#### [0.1.5] - 2026-02-11
**Day 1 of 21 - Project Planning**

##### Added
- Comprehensive project plan PDF
- README.md with full documentation
- TODO.md with detailed task breakdown
- ChangeLog.md for version tracking
- Contributing.md with coding standards
- Progress Tracker.md for daily updates

##### Changed
- Established 3-week sprint plan (21 days)
- Defined critical path tasks
- Set MVP target date: March 4, 2026

##### Infrastructure
- Created documentation standards
- Established git workflow
- Defined coding conventions

---

## [0.1.0] - 2026-01-02

### Added
- Initial project setup with SwiftUI
- Core Data model with 5 entities:
  - Transaction (expenses tracking)
  - Category (expense categorization)
  - Account (payment sources)
  - Income (income tracking)
  - SavingsPlan (savings goals)
- Tab-based navigation structure
- PersistenceController for Core Data
- CoreData+Save extension for safe context saving
- Placeholder views for all main features:
  - Dashboard
  - Manual Entry
  - Transactions
  - Budgets
  - Settings

### Infrastructure
- Created feature-based folder structure
- Set up Core Data stack with proper merge policies
- Configured environment for managed object context injection

---

## Version History

### Phase 1: Foundation (Jan 2 - Feb 11, 2026)
**Status**: ✅ Complete

**Achievements**:
- Project architecture established
- Data model designed and implemented
- Navigation structure created
- Core infrastructure in place
- Comprehensive documentation

**Next Steps**: Begin Phase 2 development

---

### Phase 2: Core Functionality (Feb 11 - Mar 4, 2026)
**Status**: 🚧 In Progress — primary UI flows shipped; polish and tests remain

**Current focus**: Tests, performance, accessibility, and export/backup hardening

**Target Features** (as of repo state, March 2026):
- Manual transaction entry ✅
- Onboarding flow ✅
- Transaction listing and management ✅
- Dashboard analytics ✅
- Category and budget management ✅ (budgets UI + settings management)
- Settings configuration ✅ (substantial settings surface)

**Expected Completion**: March 4, 2026 (MVP target)

---

### Phase 3: Advanced Features (Future)
**Status**: 📅 Planned

**Target Features**:
- Receipt scanning
- Bank integration
- Widgets
- Cloud sync
- Advanced analytics
- Export/Import functionality

---

## Development Notes

### 2026-03-20
**Focus**: Align all root `.md` files with the actual Xcode project structure and implemented features.

**Progress**:
- Documented six-entity model, `Models/` / `Views/` / `ViewModels/` / `Managers/` layout
- Recorded Transactions, Dashboard, Budgets, and Settings implementation status
- Corrected cross-file links and outdated “Week 2 Day 8 only” narrative

**Next Steps**:
- Add automated tests and refine known gaps (export, notifications, etc.)

**Blockers**: None

---

### 2026-02-18 (Day 8)
**Focus**: Documentation update & Week 2 kickoff

**Progress**:
- Updated all .md files to Feb 18, 2026
- Marked Week 1 complete (Manual Entry, onboarding, AppCoordinator)
- Set current sprint to Week 2 – Transactions & Dashboard
- Onboarding flow and Core Data model changes in place

**Next Steps** (historical): Transactions list, filtering, dashboard — **since implemented in codebase**.

**Blockers**: None

---

### 2026-02-12 (Day 2)
**Focus**: Core Data Extensions + Category Seeding

**Issues Discovered**:
- Transaction validation uses incorrect boolean logic
- Category sort descriptors have naming inconsistencies
- Need to fix validation to use guard-let pattern

**Progress**:
- Started Transaction+Extensions.swift
- Started Category+Extensions.swift
- Implemented CategorySeeder.swift
- Integrated one-time seeding into app launch
- Added CategorySeederDebugView and test helpers
- Identified and documented bugs

**Next Steps**:
- Fix validation logic bugs
- Complete Transaction and Category extensions
- Begin Account, Income, and SavingsPlan extensions

**Blockers**: None

---

### 2026-02-11 (Day 1)
**Focus**: Project Planning & Documentation

**Completed**:
- ✅ Comprehensive project plan
- ✅ README.md with full documentation
- ✅ TODO.md with detailed task breakdown
- ✅ ChangeLog.md for version tracking
- ✅ Contributing.md with coding standards
- ✅ Progress Tracker.md

**Achievements**:
- Established 21-day sprint plan
- Defined critical path tasks
- Created comprehensive documentation
- Set clear milestones

**Next Steps**:
- Begin Core Data extensions implementation
- Fix any issues discovered during initial coding

**Blockers**: None

---

### 2026-01-02 (Project Inception)
**Focus**: Initial Setup

**Completed**:
- ✅ Xcode project created
- ✅ Core Data model designed
- ✅ Basic navigation implemented
- ✅ Folder structure established

**Achievements**:
- Project foundation established
- Data model validated
- Architecture decisions made

---

## Migration Notes

_No migrations yet - first version_

### Future Migration Planning

When migrations are needed, document them here:

#### Example: Migration to v0.2.0
- Added `recurringFrequency` attribute to Transaction
- Migration: Lightweight migration, no custom policy needed
- Action: Delete and reinstall app, or clear app data

---

## Known Issues

### Active Issues (as of 2026-03-20)

_No critical issues tracked in this changelog._ File new issues in GitHub for regressions or feature gaps.

### Previously documented (resolved)

1. **Transaction+Extensions.swift** — validation used incorrect optional/`isEmpty` logic — **addressed** (guard-let style validation).
2. **Category+Extensions.swift** — sort descriptor naming / budget sort — **addressed** (see project history in TODO / Progress Tracker).

### Resolved Issues
- See “Previously documented (resolved)” above.

---

## Breaking Changes

_Document any breaking changes for future reference_

### Future Considerations
- If changing Core Data model significantly, may need migration strategy
- API changes should be documented here
- Any changes to data structure that affect saved data

---

## Testing Notes

### Manual Testing Performed
- Project builds successfully
- App launches without crashes
- Core Data stack initializes properly
- Navigation between tabs works

### Automated Testing
_Not yet implemented_

### Performance Testing
_Not yet performed_

---

## Dependencies

### Current Dependencies
- SwiftUI (built-in)
- Core Data (built-in)
- Foundation (built-in)

### Planned Dependencies
- Swift Charts (for Phase 2)
- Plaid SDK (for Phase 3)
- Vision framework (for Phase 3)

---

## Release Checklist

When ready to release v0.2.0:
- [ ] All Core Data extensions completed and tested
- [ ] Default categories seeding works
- [ ] Manual Entry form fully functional
- [ ] No known critical bugs
- [ ] Documentation updated
- [ ] Performance is acceptable
- [ ] Tested on multiple devices/simulators

---

**Note**: Keep this changelog updated with each significant change or milestone!

**Update Frequency**: Daily during active development

**Last Updated**: March 20, 2026
