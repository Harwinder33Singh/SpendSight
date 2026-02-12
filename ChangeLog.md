# Changelog
All notable changes to SpendSight will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Week 1 (Feb 11-17, 2026) - In Progress

#### [0.2.0] - 2026-02-12
**Day 2 of 21 - Core Data Extensions**

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
- CHANGELOG.md for version tracking
- CONTRIBUTING.md with coding standards
- PROGRESS_TRACKER.md for daily updates

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
**Status**: 🚧 In Progress (Day 2 of 21)

**Current Sprint**: Week 1 - Foundation & Manual Entry
**Current Task**: Core Data Extensions (Day 2-3)

**Target Features**:
- Manual transaction entry ⏳
- Transaction listing and management 📅
- Dashboard analytics 📅
- Category and budget management 📅
- Settings configuration 📅

**Expected Completion**: March 4, 2026

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

### 2026-02-12 (Day 2)
**Focus**: Core Data Extensions

**Issues Discovered**:
- Transaction validation uses incorrect boolean logic
- Category sort descriptors have naming inconsistencies
- Need to fix validation to use guard-let pattern

**Progress**:
- Started Transaction+Extensions.swift
- Started Category+Extensions.swift
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
- ✅ CHANGELOG.md for version tracking
- ✅ CONTRIBUTING.md with coding standards
- ✅ PROGRESS_TRACKER.md

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

### Active Issues (as of 2026-02-12)

1. **Transaction+Extensions.swift** - Validation Logic Bug
   - **Location**: Lines 181-194
   - **Issue**: Using `== nil` on Boolean `.isEmpty` property
   - **Impact**: Validation always fails
   - **Fix**: Use guard-let pattern with proper unwrapping
   - **Priority**: HIGH
   - **Status**: Identified, fix pending

2. **Category+Extensions.swift** - Sort Descriptor Issues
   - **Location**: Lines 85 and 91
   - **Issues**:
     - Line 85: Typo `sortByNameDecending` → should be `sortByNameDescending`
     - Line 91: `sortByNameDescending` actually sorts by budget (wrong implementation)
   - **Impact**: Sorting may not work as expected
   - **Fix**: Rename typo and correct implementation
   - **Priority**: MEDIUM
   - **Status**: Identified, fix pending

### Resolved Issues
_None yet_

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

**Last Updated**: February 12, 2026, 3:38 PM