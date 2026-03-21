# SpendSight - Development TODO

**Last Updated**: March 20, 2026  
**Current focus**: Polish, tests, and Phase 3 planning (core app flows are implemented in Xcode)

---

## 🔴 CRITICAL PATH — Status vs repo

### Task 1: Core Data extensions ✅
**Priority**: HIGHEST | **Status**: COMPLETE | **Location**: `SpendSight/Models/Extensions/`

Implemented files:
- `Transaction+Extensions.swift`
- `Category+Extensions.swift`
- `Account+Extensions.swift`
- `Income+Extensions.swift`
- `SavingsPlan+Extensions.swift`
- `UserProfile+Extensions.swift` (sixth entity — onboarding / profile)

**Acceptance criteria**: Met for shipping v1-style features; extend as new attributes ship.

---

### Task 2: Default Categories Setup (Day 4 - Feb 14) ✅
**Priority**: HIGH | **Status**: MOSTLY COMPLETE (DONE EARLY ON DAY 2) | **Depends On**: Task 1

#### CategorySeeder.swift
- [x] Create CategorySeeder utility class
- [x] Define 10 default categories array
- [x] Implement `seedIfNeeded()` method
- [x] Add check to prevent duplicate seeding (UserDefaults flag)
- [x] Add helper methods (`resetSeedingFlag`, `needsSeeding`) and debug testing helpers
- [ ] Verify seeding behavior in production UI flows

#### Default Categories to Create:
1. 🛒 **Groceries** - `#4CAF50` - `cart.fill` - Budget: $500
2. 🍕 **Dining Out** - `#FF9800` - `fork.knife` - Budget: $200
3. 🚗 **Transportation** - `#2196F3` - `car.fill` - Budget: $150
4. 🎬 **Entertainment** - `#9C27B0` - `film.fill` - Budget: $100
5. 🛍️ **Shopping** - `#E91E63` - `bag.fill` - Budget: $200
6. ⚡ **Utilities** - `#795548` - `bolt.fill` - Budget: $300
7. 🏥 **Healthcare** - `#F44336` - `cross.case.fill` - No budget
8. 💵 **Income** - `#8BC34A` - `dollarsign.circle.fill` - No budget
9. ❓ **Other** - `#9E9E9E` - `questionmark.circle.fill` - No budget
10. 🏠 **Housing** - `#607D8B` - `house.fill` - Budget: $1500

**Files**:
```
SpendSight/Models/Utilities/
└── CategorySeeder.swift
```

**Integration**:
- [x] UserDefaults key: `"hasSeededCategories"` (also cleared on `AppCoordinator.logout`)
- [x] Onboarding completion marks seeding / creates selected categories (`OnboardingViewModel` + `CategorySeeder` extension)
- [ ] Note: `CategorySeeder.seedIfNeeded` in commented `SpendSightApp` block is **not** the active path — onboarding drives first categories
- [ ] Verify edge cases: skip onboarding (if ever), reinstall, logout → re-onboard

**Acceptance Criteria**:
- ✅ Categories only seed once
- ✅ All 10 categories created with correct properties
- ✅ Colors and icons properly assigned
- [ ] Categories appear in pickers/lists
- ✅ Budgets set correctly

---

### Task 3: Manual Entry ✅
**Priority**: CRITICAL | **Status**: COMPLETE | **Path**: `SpendSight/Views/Features/ManualEntry/`

Shipped (high level):
- [x] `ManualEntryView` with validation and Core Data save
- [x] `CurrencyTextField`, `CategoryPickerView`, `AccountPickerView`

**Follow-ups (optional polish)**:
- [ ] Recurring frequency UI (beyond `isRecurring` flag)
- [ ] UX pass: keyboard focus, haptics, animation consistency

---

## 🟡 IMPORTANT — shipped in repo

### Task 4: Transactions list ✅
**Priority**: HIGH | **Status**: COMPLETE | **Files**: `TransactionsView.swift`, `TransactionComponents.swift`, `TransactionsViewModel.swift`

- [x] `@FetchRequest` + client-side filter/search via view model
- [x] Sections grouped by relative date labels
- [x] `TransactionRow`, detail navigation, swipe edit (sheet) / delete (confirm)
- [x] `FilterSheet` — date preset, categories, accounts, amount min/max
- [x] `.searchable` for text search
- [x] Empty state (`ContentUnavailableView`) + clear filters
- [x] `refreshable` → `context.refreshAllObjects()`

**Follow-ups**:
- [ ] Stress-test with 500+ rows (consider fetch limits / predicates)
- [ ] Unit tests for `matchesFilters` / predicate building

---

### Task 5: Dashboard ✅
**Priority**: HIGH | **Status**: COMPLETE (core scope) | **Files**: `DashboardView.swift`, `DashboardComponents.swift`, `DashboardViewModel.swift`

- [x] Summary cards (today, week, month, daily average)
- [x] Swift Charts: top categories + 30-day trend with moving average (`DashboardComponents`)
- [x] Floating `+` → `ManualEntryView` sheet

**Follow-ups**:
- [ ] Recent-transactions strip + “See all” (if not present in current scroll content)
- [ ] Budget overrun banner tied to live spend vs `Category.monthlyBudget`
- [ ] Chart tap-for-detail interactions

---

## 🟢 Polish & Week 3 items

### Task 6: Budget management 🚧
**Priority**: MEDIUM | **Status**: LARGELY COMPLETE in UI | **Files**: `BudgetsView.swift`, `BudgetDetailView.swift`, `AddBudgetView.swift`

- [x] Overview, active budgets, add budget flow, detail navigation
- [ ] Local notifications at 80% / 100% spend
- [ ] End-to-end tests for monthly spend math vs transactions

---

### Task 7: Settings 🚧
**Priority**: MEDIUM | **Status**: SUBSTANTIAL UI | **File**: `SettingsView.swift` (+ nested views)

- [x] Category management (`CategoryManagementView`, `AddEditCategoryView`)
- [x] Account management (`AccountManagementView`, `AddEditAccountView`)
- [x] Profile name via `@AppStorage`, multiple settings sheets (notifications, backup, help, privacy, database info in DEBUG)
- [ ] Wire **global currency** from `UserProfile` / `@AppStorage` through all formatters consistently
- [ ] CSV / PDF export and JSON backup — verify implementations vs placeholders

**Acceptance Criteria**: Track remaining items above in GitHub issues as you verify each flow.

---

## 🎯 Near-term checklist (post–doc sync)

- [ ] Add XCTest targets for `TransactionsViewModel` and `DashboardViewModel`
- [ ] Profile scrolling performance (Transactions list + Dashboard) with Instruments
- [ ] Confirm logout / `deleteAllData` also clears `Income` and `SavingsPlan` if those features are user-visible
- [ ] Add root `LICENSE` if open-sourcing

---

## 📋 Testing Checklist

### Before Each Commit
- [ ] No compiler warnings
- [ ] No force unwraps (use guard/if let)
- [ ] Code follows Swift conventions
- [ ] Comments added for complex logic
- [ ] Manual testing performed
- [ ] Git commit message is descriptive

### Before Each Milestone
- [ ] All features work as expected
- [ ] Edge cases tested
- [ ] Performance is acceptable
- [ ] No memory leaks (use Instruments)
- [ ] UI is responsive
- [ ] Error handling works

---

## 🐛 Known Issues / Technical Debt

### Active Issues
_None._

### Resolved Issues
- Transaction validation logic (guard-let pattern in place)
- Category sort: renamed `sortByNameDescendingMonthlyBudget` → `sortByBudgetDescending`
- Category default list: added "Housing" to `createDefaultCategories`
- Comment typos: `Mark` → `MARK`, `Convinience` → `Convenience` in extensions

---

## 💡 Ideas / Future Enhancements

- [ ] Dark mode optimization
- [ ] iPad layout improvements
- [ ] Accessibility improvements (VoiceOver)
- [ ] Localization support
- [ ] Export to PDF reports
- [ ] Siri shortcuts integration
- [ ] Apple Watch companion app
- [ ] Face ID for app lock
- [ ] Custom category creation
- [ ] Tags for transactions
- [ ] Merchant autocomplete
- [ ] Photo attachments for receipts

---

## 📝 Notes

### Development Setup
- Xcode version: 15.0+
- iOS deployment target: 16.0
- Swift version: 5.9

### Useful Commands
```bash
# Clean build folder
Cmd + Shift + K

# Clean derived data
Cmd + Option + Shift + K

# Run tests
Cmd + U

# Build for testing
Cmd + Shift + U

# Show/hide debug area
Cmd + Shift + Y

# Quick Open
Cmd + Shift + O
```

### Core Data Debugging
```bash
# View Core Data SQL
# Add to scheme arguments:
-com.apple.CoreData.SQLDebug 1

# Find simulator documents directory
po FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

# Use DB Browser for SQLite to inspect database
```

### Git Workflow
```bash
# Check status
git status

# Stage changes
git add .

# Commit with message
git commit -m "fix: correct Transaction validation logic"

# View commit history
git log --oneline -10

# Create feature branch
git checkout -b feature/manual-entry-form

# Merge to main
git checkout main
git merge feature/manual-entry-form
```

### Useful Resources
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Core Data Documentation](https://developer.apple.com/documentation/coredata)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Swift Charts](https://developer.apple.com/documentation/charts)
- [SF Symbols App](https://developer.apple.com/sf-symbols/)

---

**Remember**: Critical path for MVP UI is largely complete; prioritize **tests**, **data safety** (logout/backup), and **Phase 3** features you want next.
