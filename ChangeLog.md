# Changelog

All notable changes to SpendSight will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Week 1 (In Progress)
- Core Data extensions for Transaction and Category entities (in progress)
- Default category seeding system (scheduled for Feb 14)
- Manual transaction entry form (planning UI & validation)

### Week 2 (Planned)
- Transactions list with filtering
- Dashboard with spending analytics
- Swift Charts integration
  (Manual entry work blocks start of Week 2 deliverables)

### Week 3 (Planned)
- Budget management system
- Settings and account management
- Data export functionality

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

**Next Steps**: Begin Phase 2 development

---

### Phase 2: Core Functionality (Feb 11 - Mar 4, 2026)
**Status**: 🚧 In Progress (Manual entry prioritized)

**Target Features**:
- Manual transaction entry
- Transaction listing and management
- Dashboard analytics
- Category and budget management
- Settings configuration

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

### 2026-02-11
- Created comprehensive project plan
- Established 3-week development timeline
- Prioritized critical path tasks
- Documented all features and requirements

### 2026-02-12
- Started implementing Transaction and Category Core Data extensions
- Drafted Manual Entry form wireframes and validation criteria
- Scheduled default category seeding for Feb 14 launch prep

### 2026-01-02
- Project inception
- Initial Xcode project created
- Core Data model designed
- Basic navigation implemented

---

## Migration Notes

_No migrations yet - first version_

When migrations are needed, document them here:

### Migration to v0.2.0 (Example)
- Added `recurringFrequency` attribute to Transaction
- Migration: Lightweight migration, no custom policy needed
- Action: Delete and reinstall app, or clear app data

---

## Known Issues

_Track bugs and issues here as they're discovered_

### Active Issues
None currently

### Resolved Issues
None yet

---

## Breaking Changes

_Document any breaking changes for future reference_

### Future Considerations
- If changing Core Data model significantly, may need migration strategy
- API changes should be documented here
- Any changes to data structure that affect saved data

---

**Note**: Keep this changelog updated with each significant change or milestone!
