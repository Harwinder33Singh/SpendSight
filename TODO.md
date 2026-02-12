# SpendSight - Development TODO

**Last Updated**: February 12, 2026  
**Current Sprint**: Week 1 - Foundation & Manual Entry

---

## 🔴 CRITICAL PATH - Do These First

### Task 1: Core Data Extensions (Days 1-2) ⏳
**Priority**: HIGHEST | **Status**: NOT STARTED | **Blocker**: None

#### Transaction+Extensions.swift
- [ ] Create convenience initializer
- [ ] Add `displayDate` computed property
- [ ] Add `formattedAmount` computed property
- [ ] Add `categoryName` computed property
- [ ] Add `accountName` computed property
- [ ] Create fetch request builder
- [ ] Add validation methods
- [ ] Test all extensions

#### Category+Extensions.swift
- [ ] Create convenience initializer with defaults
- [ ] Add `hexColor` computed property for Color conversion
- [ ] Add `sfSymbol` computed property
- [ ] Create fetch request for all categories
- [ ] Add sort descriptor helpers
- [ ] Test category creation and retrieval

#### Account+Extensions.swift
- [ ] Create convenience initializer
- [ ] Add `displayName` computed property (name + last4)
- [ ] Add `formattedLast4` computed property
- [ ] Create fetch request builder
- [ ] Add validation for institution/last4
- [ ] Test account operations

#### Income+Extensions.swift
- [ ] Create convenience initializer
- [ ] Add `formattedAmount` computed property
- [ ] Add `displayDate` computed property
- [ ] Create fetch requests by date range
- [ ] Test income tracking

#### SavingsPlan+Extensions.swift
- [ ] Create convenience initializer
- [ ] Add `progressPercentage` computed property
- [ ] Add `remainingAmount` computed property
- [ ] Add `isComplete` computed property
- [ ] Create fetch request for active plans
- [ ] Test savings calculations

Current focus is Transaction and Category convenience helpers; Account, Income, and SavingsPlan extensions follow once these stabilize.

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
- ✅ No compiler warnings or errors
- ✅ Manual testing passes for all extensions

---

### Task 2: Default Categories Setup (Day 3) ⏳
**Priority**: HIGH | **Status**: PLANNED (seeding scheduled for Feb 14) | **Depends On**: Task 1

#### CategorySeeder.swift
- [ ] Create CategorySeeder utility class
- [ ] Define 10 default categories array
- [ ] Implement `seedIfNeeded()` method
- [ ] Add check to prevent duplicate seeding
- [ ] Test seeding on first launch

#### Default Categories to Create:
1. 🍔 **Food & Dining** - #FF6B6B
2. 🚗 **Transportation** - #4ECDC4
3. 🏠 **Housing** - #FFE66D
4. 💡 **Utilities** - #95E1D3
5. 🎬 **Entertainment** - #C7CEEA
6. 🛒 **Shopping** - #FFDAB9
7. 💊 **Healthcare** - #B8E6B8
8. 📚 **Education** - #DDA0DD
9. ✈️ **Travel** - #87CEEB
10. 💰 **Other** - #D3D3D3

**SF Symbols to Use**:
- fork.knife (Food)
- car.fill (Transportation)
- house.fill (Housing)
- bolt.fill (Utilities)
- film.fill (Entertainment)
- bag.fill (Shopping)
- cross.case.fill (Healthcare)
- book.fill (Education)
- airplane (Travel)
- questionmark.circle.fill (Other)

**Files to Create**:
```
SpendSight/Core/Utilities/
└── CategorySeeder.swift
```

**Integration**:
- [ ] Call seeder in `SpendSightApp.swift` on first launch
- [ ] Add UserDefaults flag to track seeding status
- [ ] Test category creation and display

**Acceptance Criteria**:
- ✅ Categories only seed once
- ✅ All 10 categories created with correct properties
- ✅ Colors and icons properly assigned
- ✅ Categories appear in pickers/lists

---

### Task 3: Manual Entry Form (Days 4-7) ⏳
**Priority**: CRITICAL | **Status**: IN PROGRESS (wireframes & validation defined) | **Depends On**: Task 1, 2

#### ManualEntryView.swift - Complete Rewrite
- [ ] Create form state management with @State variables
- [ ] Implement amount input field
  - [ ] NumberPad keyboard
  - [ ] Currency formatting as you type
  - [ ] Validation (must be > 0)
- [ ] Add date picker
  - [ ] Default to today
  - [ ] Prevent future dates
  - [ ] Nice date display
- [ ] Create category picker
  - [ ] Grid layout (2 columns)
  - [ ] Show icon + name + color
  - [ ] Selection highlighting
- [ ] Build account selector
  - [ ] Dropdown or picker
  - [ ] Show account name + last4
  - [ ] Remember last used
- [ ] Add merchant/title field
  - [ ] Text field with placeholder
  - [ ] Auto-capitalization
  - [ ] Optional but recommended
- [ ] Implement payment method picker
  - [ ] Credit Card, Debit Card, Cash, Other
  - [ ] Default to last used
- [ ] Create notes field
  - [ ] Multi-line TextEditor
  - [ ] Optional
  - [ ] Character limit (200)
- [ ] Add recurring toggle
  - [ ] Simple Toggle switch
  - [ ] Phase 2: frequency picker
- [ ] Build save button
  - [ ] Validation before save
  - [ ] Loading state
  - [ ] Success feedback (haptic + animation)
  - [ ] Error handling
- [ ] Add cancel/reset functionality

#### Form Validation
- [ ] Amount must be greater than 0
- [ ] Date cannot be in future
- [ ] Category must be selected
- [ ] Account must be selected
- [ ] Merchant minimum 2 characters (if provided)

#### UI/UX Polish
- [ ] Auto-focus on amount field when view appears
- [ ] Keyboard dismissal on tap outside
- [ ] Smooth animations for picker transitions
- [ ] Clear visual feedback for validation errors
- [ ] Success animation after save
- [ ] Form resets after successful save

**Files to Modify**:
```
SpendSight/Features/ManualEntry/
└── ManualEntryView.swift (complete rewrite)
```

**Optional: Create Reusable Components**:
```
SpendSight/Shared/Components/
├── CategoryPickerView.swift
├── AccountPickerView.swift
└── CurrencyTextField.swift
```

**Acceptance Criteria**:
- ✅ Form validation works correctly
- ✅ Transactions save to Core Data
- ✅ All fields update state properly
- ✅ UI is intuitive and responsive
- ✅ No crashes on save/cancel
- ✅ Data persists after app restart

Manual entry doc already captures field requirements, validation rules, and save feedback expectations before coding begins.

---

## 🟡 IMPORTANT - Do These Second (Week 2)

### Task 4: Transactions List View (Days 8-11) ⏸️
**Priority**: HIGH | **Status**: NOT STARTED | **Depends On**: Task 1, 3

#### TransactionsView.swift - Complete Rewrite
- [ ] Fetch transactions from Core Data
- [ ] Group by date (sections)
- [ ] Create transaction row design
- [ ] Implement swipe-to-delete
- [ ] Add tap-to-edit navigation
- [ ] Build filter sheet
- [ ] Add search bar
- [ ] Create empty state
- [ ] Implement pull-to-refresh

#### Transaction Row Component
- [ ] Show category icon with color
- [ ] Display merchant/title
- [ ] Show formatted amount
- [ ] Include date
- [ ] Add account indicator

#### Filtering Options
- [ ] Date range filter (This Week, This Month, Custom)
- [ ] Category filter (multi-select)
- [ ] Account filter
- [ ] Amount range filter

**Acceptance Criteria**:
- ✅ Transactions display correctly
- ✅ Filtering works as expected
- ✅ Delete/edit operations succeed
- ✅ Performance is smooth with 100+ transactions

---

### Task 5: Dashboard View (Days 12-14) ⏸️
**Priority**: HIGH | **Status**: NOT STARTED | **Depends On**: Task 1, 4

#### DashboardView.swift - Complete Rewrite
- [ ] Create spending summary cards
- [ ] Build "This Month" total widget
- [ ] Add "Today" spending widget
- [ ] Implement top categories chart (pie or bar)
- [ ] Show recent transactions (last 5)
- [ ] Add budget progress indicators
- [ ] Create quick-add floating button
- [ ] Design budget overrun alerts

#### Swift Charts Integration
- [ ] Add Swift Charts import
- [ ] Create spending by category chart
- [ ] Add spending trend over time chart
- [ ] Make charts interactive

**Acceptance Criteria**:
- ✅ Dashboard loads quickly
- ✅ Charts render correctly
- ✅ Data updates in real-time
- ✅ Quick-add button navigates to Manual Entry

---

## 🟢 NICE TO HAVE - Polish (Week 3)

### Task 6: Budget Management (Days 15-18) ⏸️
**Priority**: MEDIUM | **Status**: NOT STARTED

- [ ] Create budget overview screen
- [ ] Build budget setting UI per category
- [ ] Implement progress bars
- [ ] Add budget vs. actual comparison
- [ ] Create 80%/100% notifications

---

### Task 7: Settings View (Days 19-21) ⏸️
**Priority**: MEDIUM | **Status**: NOT STARTED

- [ ] Build account management screen
- [ ] Add/edit/delete accounts UI
- [ ] Create default account selection
- [ ] Implement currency selection
- [ ] Add data export functionality
- [ ] Build backup/restore feature

---

## 🎯 Daily Checklist

### Today's Focus (Day 1)
- [ ] Read and understand project plan PDF
- [ ] Set up development environment
- [ ] Create Core Data extensions folder
- [ ] Start Transaction+Extensions.swift
- [ ] Write tests for Transaction extensions

### Tomorrow (Day 2)
- [ ] Complete remaining entity extensions
- [ ] Test all extensions thoroughly
- [ ] Create CategorySeeder.swift
- [ ] Begin default categories setup

### Day 3
- [ ] Complete CategorySeeder implementation
- [ ] Test category seeding
- [ ] Start Manual Entry form UI layout
- [ ] Design form structure

### Days 4-7
- [ ] Build out Manual Entry form
- [ ] Implement form validation
- [ ] Add save functionality
- [ ] Test end-to-end transaction creation

---

## 📋 Testing Checklist

### Before Each Commit
- [ ] No compiler warnings
- [ ] No force unwraps (use guard/if let)
- [ ] Code follows Swift conventions
- [ ] Comments added for complex logic
- [ ] Manual testing performed

### Before Each Milestone
- [ ] All features work as expected
- [ ] Edge cases tested
- [ ] Performance is acceptable
- [ ] No memory leaks (use Instruments)
- [ ] UI is responsive

---

## 🐛 Known Issues / Technical Debt

_None yet - update as issues are discovered_

---

## 💡 Ideas / Future Enhancements

- [ ] Dark mode optimization
- [ ] iPad layout improvements
- [ ] Accessibility improvements (VoiceOver)
- [ ] Localization support
- [ ] Export to PDF reports
- [ ] Siri shortcuts integration
- [ ] Apple Watch companion app

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

# View Core Data database
# Use DB Browser for SQLite or Xcode's Core Data debug tools
```

### Useful Resources
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Core Data Documentation](https://developer.apple.com/documentation/coredata)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Swift Charts](https://developer.apple.com/documentation/charts)

---

**Remember**: Focus on the critical path! Complete Task 1-3 before moving to Week 2 tasks.
