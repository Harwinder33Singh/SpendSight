# SpendSight 💰

<p align="center">
  <img src="https://img.shields.io/badge/iOS-16.0+-blue.svg" />
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" />
  <img src="https://img.shields.io/badge/SwiftUI-3.0-green.svg" />
  <img src="https://img.shields.io/badge/Status-In%20Development-yellow.svg" />
</p>

> A modern iOS expense tracking application built with SwiftUI and Core Data to help users better manage their finances.

## 📱 Overview

SpendSight is a personal finance tracking app that makes it easy to:
- 📝 Manually log expenses with detailed categorization
- 📊 Visualize spending patterns with interactive charts
- 💼 Manage multiple accounts and payment methods
- 🎯 Set and track category-based budgets
- 💾 Store all data locally with Core Data

## ✨ Features

### Current (Phase 1) ✅
- [x] Core Data model with 5 entities
- [x] Tab-based navigation structure
- [x] Persistence layer setup
- [x] Project architecture established
- [x] Default category seeding system (10 categories, first-launch only)

### In Development (Phase 2) 🚧
- [x] Manual transaction entry with form validation (Week 1 – done)
- [ ] Transaction list with filtering and search (Week 2 – in progress)
- [ ] Dashboard with spending analytics (Week 2)
- [x] Onboarding flow and first-launch experience
- [ ] Budget tracking with progress indicators (Week 3)
- [ ] Settings and account management (Week 3)

### Planned (Phase 3+) 📅
- [ ] Receipt scanning with Vision framework
- [ ] Bank integration via Plaid API
- [ ] Recurring transaction automation
- [ ] Home Screen widgets
- [ ] iCloud sync
- [ ] CSV import/export
- [ ] Advanced analytics

## 🏗 Architecture

### Project Structure
```
SpendSight/
├── App/
│   └── SpendSightApp.swift          # App entry point
├── Core/
│   ├── CoreData+Save.swift          # Context extensions
│   ├── PersistenceController.swift  # Core Data stack
│   └── Extensions/                  # Core Data entity extensions
│       ├── Transaction+Extensions.swift
│       ├── Category+Extensions.swift
│       ├── Account+Extensions.swift
│       ├── Income+Extensions.swift
│       └── SavingsPlan+Extensions.swift
├── Features/
│   ├── Budgets/
│   │   └── BudgetsView.swift
│   ├── Dashboard/
│   │   └── DashboardView.swift
│   ├── ManualEntry/
│   │   └── ManualEntryView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Transactions/
│       └── TransactionsView.swift
└── Resources/
    └── TrackSpendture.xcdatamodeld  # Core Data model
```

### Data Model

#### Core Entities

**Transaction** (Primary Entity)
- Tracks individual expenses/purchases
- Links to Category and Account
- Supports recurring transactions
- Timestamps for audit trail

**Category**
- Organizes transactions by type
- Custom icons and colors
- Monthly budget allocation

**Account**
- Represents bank accounts/payment methods
- Tracks both expenses and income
- Institution details (name, last4, type)

**Income**
- Separate tracking for income sources
- Links to Account entity
- Date-based tracking

**SavingsPlan**
- Goal-based savings tracking
- Target and current amount
- Monthly tracking

### Technology Stack

- **Framework**: SwiftUI
- **Persistence**: Core Data
- **Charts**: Swift Charts (planned)
- **Architecture**: MVVM pattern
- **Minimum iOS**: 16.0+

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 16.0+ device or simulator
- macOS 13.0+ (for development)

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/SpendSight.git
cd SpendSight
```

2. Open in Xcode
```bash
open SpendSight.xcodeproj
```

3. Build and run
- Select your target device/simulator
- Press `Cmd + R` or click the Run button

### First Time Setup

The app will automatically:
- Initialize Core Data stack
- Create 10 default categories on first launch
- Set up persistence layer

## 📖 Usage

### Adding a Transaction (Coming Soon)
1. Tap the "Manual Entry" tab
2. Enter the amount
3. Select a category
4. Choose an account
5. Add optional notes
6. Tap "Save"

### Viewing Transactions (Coming Soon)
1. Navigate to "Transactions" tab
2. Use filters to narrow results
3. Swipe to delete or tap to edit

### Setting Budgets (Coming Soon)
1. Go to "Budgets" tab
2. Select a category
3. Set monthly budget amount
4. Track progress throughout the month

## 🛠 Development

### Current Sprint (Week 2: Feb 18-24, 2026)
**Goal**: Transactions list and dashboard

**Status**: Day 8 of 21 - 🚧 In Progress (Week 1 complete)

- [x] Task 1: Core Data extensions (completed Feb 12)
- [x] Task 2: Default categories setup (completed Feb 12)
- [x] Task 3: Manual Entry form (completed Feb 15-17)
  - [x] Full form UI with validation
  - [x] Save to Core Data
  - [x] Onboarding flow (OnboardingView, OnboardingViewModel, OnboardingStepViews, AddAccountSheet)
  - [x] AppCoordinator (loading → onboarding → main)

- [ ] Task 4: Transactions list (Week 2 – in progress)
  - [ ] Fetch and display transactions
  - [ ] Transaction row, swipe-to-delete, tap-to-edit
  - [ ] Filtering and search

**Milestone**: Users can view and manage transactions

### Development Guidelines

#### Code Style
- Use meaningful variable names
- Follow Swift naming conventions
- Add comments for complex logic
- Keep functions focused and small

#### Core Data Best Practices
- Always check for context changes before saving
- Use background contexts for heavy operations
- Implement proper error handling
- Test cascade delete rules
- Use guard statements instead of force unwrapping

#### SwiftUI Best Practices
- Keep views small and composable
- Extract reusable components
- Use @StateObject for owned objects
- Use @ObservedObject for passed objects

### Testing Strategy

1. **Unit Tests** (Planned)
   - Core Data operations
   - Business logic
   - Validation functions

2. **Integration Tests** (Planned)
   - Data flow between views
   - Navigation logic
   - State management

3. **Manual Testing** (Current)
   - Feature testing as built
   - Edge case validation
   - UI/UX verification

## 📝 Roadmap

### Week 1: Foundation (Days 1-7) ✅
- [x] Day 1: Project planning & documentation (Feb 11)
- [x] Days 2-3: Core Data extensions (Feb 12)
- [x] Day 4 scope (default categories seeding) completed early
- [x] Days 5-7: Manual entry form + onboarding (Feb 15-17)

### Week 2: Core Features (Current - Days 8-14)
- [ ] Transactions list view (Feb 18+)
- [ ] Dashboard with charts
- [ ] Basic filtering
- [ ] Search functionality

### Week 3: Polish & Budget (Days 15-21)
- [ ] Budget management
- [ ] Settings view
- [ ] Data validation
- [ ] Final testing

### Phase 2 (Future)
- [ ] Advanced analytics
- [ ] Receipt scanning
- [ ] Bank integration
- [ ] Cloud sync

## 🤝 Contributing

This is currently a personal project. If you'd like to contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**Harwinder Singh**
- Started: January 2, 2026
- Status: Active Development (Day 8 of 21)

## 📞 Support

For questions or issues:
- Create an issue in the GitHub repository
- Review [PROGRESS_TRACKER.md](PROGRESS_TRACKER.md) for current sprint
- Check [TODO.md](TODO.md) for task details
- See [CHANGELOG.md](CHANGELOG.md) for recent updates

## 🙏 Acknowledgments

- SwiftUI documentation and community
- Core Data best practices from Apple
- iOS design patterns and guidelines

## 📊 Project Status

**Last Updated**: February 18, 2026

**Current Phase**: Phase 2 - Core Functionality

**Current Task**: Transactions list view – fetch, display, and basic interactions

**Sprint**: Week 2, Day 8 of 21

**Next Milestone**: Transactions list with filters and search (Feb 21)

**Target MVP Date**: March 4, 2026

**Latest Update**: Week 1 complete (Manual Entry form, onboarding flow, AppCoordinator). Documentation updated. Starting Week 2: transactions list and dashboard.

---

<p align="center">Made with ❤️ in SwiftUI</p>
