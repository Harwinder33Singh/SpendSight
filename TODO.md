# SpendSight - Development TODO

**Last Updated**: February 18, 2026  
**Current Sprint**: Week 2 - Transactions & Dashboard  
**Sprint Day**: 8 of 21

---

## 🔴 CRITICAL PATH - Do These First

### Task 1: Core Data Extensions (Days 2-3) ⏳
**Priority**: HIGHEST | **Status**: IN PROGRESS | **Blocker**: None

#### Transaction+Extensions.swift ⏳
- [ ] Create convenience initializer
- [ ] Add `displayDate` computed property
- [ ] Add `formattedAmount` computed property
- [ ] Add `categoryName` computed property
- [ ] Add `accountName` computed property
- [ ] Add `isExpense` and `isIncome` computed properties
- [ ] Add `absoluteAmount` computed property
- [ ] Create fetch request builder with filters

#### Category+Extensions.swift ⏳
- [ ] Create convenience initializer with defaults
- [ ] Add `color` computed property for SwiftUI Color
- [ ] Add `hexColor` computed property
- [ ] Add `sfSymbol` computed property
- [ ] Add budget-related computed properties
- [ ] Create fetch request for all categories
- [ ] Add sort descriptor helpers
- [ ] Test category creation and retrieval

#### Account+Extensions.swift
- [ ] Create convenience initializer
- [ ] Add `displayName` computed property (name + institution)
- [ ] Add `formattedLast4` computed property (••••1234)
- [ ] Add balance calculation methods
- [ ] Create fetch request builder
- [ ] Add validation for institution/last4
- [ ] Test account operations

#### Income+Extensions.swift
- [ ] Create convenience initializer
- [ ] Add `formattedAmount` computed property
- [ ] Add `displayDate` computed property
- [ ] Add `accountName` computed property
- [ ] Create fetch requests by date range
- [ ] Add validation methods
- [ ] Test income tracking

#### SavingsPlan+Extensions.swift
- [ ] Create convenience initializer
- [ ] Add `progressPercentage` computed property
- [ ] Add `remainingAmount` computed property
- [ ] Add `isComplete` computed property
- [ ] Add `formattedTargetAmount` computed property
- [ ] Create fetch request for active plans
- [ ] Add validation methods
- [ ] Test savings calculations

**Files to Create**:
```
SpendSight/Core/Extensions/
├── Transaction+Extensions.swift
├── Category+Extensions.swift 
├── Account+Extensions.swift
├── Income+Extensions.swift
└── SavingsPlan+Extensions.swift
```

**Acceptance Criteria**:
- ✅ All entities have convenience initializers
- ✅ Display properties are formatted correctly
- ✅ Fetch requests return expected data
- ✅ Validation logic works correctly (use guard statements)
- ✅ No compiler warnings or errors
- ✅ Manual testing passes for all extensions

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

**Files to Create**:
```
SpendSight/Core/Utilities/
└── CategorySeeder.swift
```

**Integration**:
- [x] Call seeder in `SpendSightApp.swift` on first launch
- [x] Add UserDefaults key: `"hasSeededCategories"`
- [x] Add debug view/actions for category creation/reset validation
- [ ] Test category creation in non-debug user flows (pickers/lists)

**Acceptance Criteria**:
- ✅ Categories only seed once
- ✅ All 10 categories created with correct properties
- ✅ Colors and icons properly assigned
- [ ] Categories appear in pickers/lists
- ✅ Budgets set correctly

---

### Task 3: Manual Entry Form (Days 5-7 - Feb 15-17) ✅
**Priority**: CRITICAL | **Status**: COMPLETE | **Depends On**: Task 1, 2

#### ManualEntryView.swift - Complete Rewrite
- [ ] Create form state management with @State variables
  - [ ] amount: Double
  - [ ] selectedDate: Date
  - [ ] selectedCategory: Category?
  - [ ] selectedAccount: Account?
  - [ ] merchant: String
  - [ ] title: String
  - [ ] notes: String
  - [ ] paymentMethod: String
  - [ ] isRecurring: Bool
  - [ ] showValidationError: Bool
  - [ ] errorMessage: String

- [ ] Implement amount input field
  - [ ] NumberPad keyboard
  - [ ] Currency formatting as you type
  - [ ] Validation (must be > 0)
  - [ ] Custom CurrencyTextField component

- [ ] Add date picker
  - [ ] Default to today
  - [ ] Prevent future dates
  - [ ] Nice date display format

- [ ] Create category picker
  - [ ] Grid layout (2 columns)
  - [ ] Show icon + name + color
  - [ ] Selection highlighting
  - [ ] Fetch categories from Core Data

- [ ] Build account selector
  - [ ] Picker or dropdown
  - [ ] Show account name + last4
  - [ ] Remember last used account (UserDefaults)

- [ ] Add merchant/title field
  - [ ] Text field with placeholder
  - [ ] Auto-capitalization
  - [ ] Minimum 2 characters validation

- [ ] Implement payment method picker
  - [ ] Options: Credit Card, Debit Card, Cash, Other
  - [ ] Default to last used
  - [ ] Save selection to UserDefaults

- [ ] Create notes field
  - [ ] Multi-line TextEditor
  - [ ] Optional
  - [ ] Character limit (200)
  - [ ] Show character count

- [ ] Add recurring toggle
  - [ ] Simple Toggle switch
  - [ ] Phase 2 will add frequency picker

- [ ] Build save button
  - [ ] Validation before save
  - [ ] Loading state indicator
  - [ ] Success feedback (haptic + animation)
  - [ ] Error handling with alert
  - [ ] Create Transaction with all fields
  - [ ] Save to Core Data context

- [ ] Add cancel/reset functionality
  - [ ] Clear all fields button
  - [ ] Confirmation dialog

#### Form Validation Rules
- [ ] Amount must be greater than 0
- [ ] Date cannot be in future
- [ ] Category must be selected (required)
- [ ] Account must be selected (required)
- [ ] Merchant minimum 2 characters (if provided)
- [ ] Title minimum 2 characters (if provided)
- [ ] Notes max 200 characters

#### UI/UX Polish
- [ ] Auto-focus on amount field when view appears
- [ ] Keyboard dismissal on tap outside
- [ ] Smooth animations for picker transitions
- [ ] Clear visual feedback for validation errors
- [ ] Success animation after save (checkmark + fade)
- [ ] Form resets after successful save
- [ ] Haptic feedback on save

**Files to Create/Modify**:
```
SpendSight/Features/ManualEntry/
└── ManualEntryView.swift (complete rewrite)

Optional Reusable Components:
SpendSight/Shared/Components/
├── CategoryPickerView.swift
├── AccountPickerView.swift
└── CurrencyTextField.swift
```

**Acceptance Criteria**:
- ✅ Form validation works correctly
- ✅ Transactions save to Core Data successfully
- ✅ All fields update state properly
- ✅ UI is intuitive and responsive
- ✅ No crashes on save/cancel
- ✅ Data persists after app restart
- ✅ Validation errors show clear messages
- ✅ Success feedback is satisfying

---

## 🟡 IMPORTANT - Do These Second (Week 2)

### Task 4: Transactions List View (Days 8-11) 📅
**Priority**: HIGH | **Status**: NOT STARTED | **Depends On**: Task 1, 3

#### TransactionsView.swift - Complete Rewrite
- [ ] Set up Core Data fetch request with @FetchRequest
- [ ] Group transactions by date (sections)
- [ ] Create transaction row component
  - [ ] Category icon with color
  - [ ] Merchant/title
  - [ ] Formatted amount (color-coded: red for expenses, green for income)
  - [ ] Date
  - [ ] Account indicator
- [ ] Implement swipe-to-delete
  - [ ] Confirmation alert
  - [ ] Delete from Core Data
  - [ ] Refresh list
- [ ] Add tap-to-edit navigation
  - [ ] Navigate to edit view (or sheet)
  - [ ] Pre-fill form with transaction data
- [ ] Build filter sheet
  - [ ] Date range filter (Today, This Week, This Month, Custom)
  - [ ] Category filter (multi-select)
  - [ ] Account filter
  - [ ] Amount range filter
  - [ ] Apply/clear filter buttons
- [ ] Add search bar
  - [ ] Search by merchant
  - [ ] Search by title
  - [ ] Search by notes
- [ ] Create empty state
  - [ ] Friendly message
  - [ ] "Add Transaction" button
  - [ ] Illustration
- [ ] Implement pull-to-refresh

**Acceptance Criteria**:
- ✅ Transactions display correctly
- ✅ Grouping by date works
- ✅ Filtering works as expected
- ✅ Delete/edit operations succeed
- ✅ Performance is smooth with 100+ transactions
- ✅ Search returns relevant results

---

### Task 5: Dashboard View (Days 12-14) 📅
**Priority**: HIGH | **Status**: NOT STARTED | **Depends On**: Task 1, 4

#### DashboardView.swift - Complete Rewrite
- [ ] Create spending summary cards
  - [ ] This Month total
  - [ ] Today total
  - [ ] This Week total
  - [ ] Average daily spending
- [ ] Build top categories chart
  - [ ] Use Swift Charts
  - [ ] Pie chart or bar chart
  - [ ] Show top 5 categories
  - [ ] Color-coded by category
- [ ] Add spending trend chart
  - [ ] Line chart showing last 30 days
  - [ ] Daily spending amount
  - [ ] Moving average line
- [ ] Show recent transactions (last 5)
  - [ ] Mini transaction rows
  - [ ] "See All" button
- [ ] Add budget progress indicators
  - [ ] Progress bars for each category with budget
  - [ ] Color coding: green < 80%, yellow 80-100%, red > 100%
  - [ ] Remaining amount display
- [ ] Create quick-add floating button
  - [ ] Fixed position
  - [ ] Navigate to Manual Entry
  - [ ] Nice animation
- [ ] Design budget overrun alerts
  - [ ] Banner at top if over budget
  - [ ] Dismiss button
  - [ ] List categories over budget

#### Swift Charts Integration
- [ ] Import Charts framework
- [ ] Create CategorySpendingChart component
- [ ] Create SpendingTrendChart component
- [ ] Make charts interactive (tap for details)
- [ ] Add loading states

**Acceptance Criteria**:
- ✅ Dashboard loads quickly
- ✅ Charts render correctly
- ✅ Data updates in real-time
- ✅ Quick-add button navigates correctly
- ✅ Budget alerts show when appropriate
- ✅ Performance is smooth

---

## 🟢 NICE TO HAVE - Polish (Week 3)

### Task 6: Budget Management (Days 15-18) 📅
**Priority**: MEDIUM | **Status**: NOT STARTED

- [ ] Create budget overview screen
  - [ ] List all categories
  - [ ] Show current budget vs. actual
  - [ ] Progress bars
  - [ ] Edit button per category
- [ ] Build budget setting UI per category
  - [ ] Enter monthly budget amount
  - [ ] Save to category entity
  - [ ] Validation (> 0)
- [ ] Implement progress calculations
  - [ ] Calculate spent this month
  - [ ] Calculate remaining
  - [ ] Calculate percentage
- [ ] Add budget vs. actual comparison
  - [ ] Visual indicators
  - [ ] Color coding
- [ ] Create notifications for budget alerts
  - [ ] 80% warning
  - [ ] 100% alert
  - [ ] Local notifications (Phase 2)

**Acceptance Criteria**:
- ✅ Can set budgets for categories
- ✅ Progress calculates correctly
- ✅ Visual feedback is clear
- ✅ Alerts trigger at correct thresholds

---

### Task 7: Settings View (Days 19-21) 📅
**Priority**: MEDIUM | **Status**: NOT STARTED

- [ ] Build account management screen
  - [ ] List all accounts
  - [ ] Add new account form
  - [ ] Edit account details
  - [ ] Delete account (with warning)
- [ ] Create default account selection
  - [ ] Picker for default account
  - [ ] Save to UserDefaults
- [ ] Implement currency selection
  - [ ] USD, EUR, GBP, etc.
  - [ ] Save to UserDefaults
  - [ ] Update all formatting
- [ ] Add data export functionality
  - [ ] Export to CSV
  - [ ] Export to PDF report
  - [ ] Share sheet
- [ ] Build backup/restore feature
  - [ ] Export Core Data to JSON
  - [ ] Import JSON to Core Data
  - [ ] Validation on import

**Acceptance Criteria**:
- ✅ Can manage accounts
- ✅ Default account works
- ✅ Currency changes apply globally
- ✅ Export creates valid files
- ✅ Backup/restore works without data loss

---

## 🎯 Daily Checklist

### Today (Day 8 - Feb 18)
- [ ] Transactions list view – basic fetch and display
- [ ] Transaction row component (category icon, merchant, amount, date)
- [ ] Begin filter/section by date
- [ ] Review onboarding flow integration

### Tomorrow (Day 9 - Feb 19)
- [ ] Transaction row design & swipe-to-delete
- [ ] Tap-to-edit navigation
- [ ] Empty state for transactions list

### Days 10-11 (Feb 20-21)
- [ ] Filtering & search functionality
- [ ] Transactions testing with various data sets

### Week 2 (Feb 18-24)
- [ ] Dashboard layout & summary cards (Days 12-14)
- [ ] Dashboard charts (Swift Charts)
- [ ] Dashboard testing & polish

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

**Remember**: Focus on the critical path! Complete Tasks 1-3 before moving to Week 2.

**Priority Order**: Fix bugs → Complete extensions → Seed categories → Build form
