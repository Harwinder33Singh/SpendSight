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

### Current (Phase 1)
- [x] Core Data model with 5 entities
- [x] Tab-based navigation structure
- [x] Persistence layer setup
- [x] Project architecture established

### In Development (Phase 2)
- [ ] Manual transaction entry with form validation (In progress)
- [ ] Transaction list with filtering and search
- [ ] Dashboard with spending analytics
- [ ] Category management with icons and colors
- [ ] Budget tracking with progress indicators
- [ ] Settings and account management

### Planned (Phase 3+)
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
│   └── PersistenceController.swift  # Core Data stack
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
- Create default categories (once implemented)
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

### Current Sprint (Week 1)
**Goal**: Manual Entry & Core Data Extensions

- [ ] Task 1: Create Core Data extensions (Days 1-2)
  - Transaction+Extensions.swift
  - Category+Extensions.swift
  - Account+Extensions.swift
  - Income+Extensions.swift
  - SavingsPlan+Extensions.swift

- [ ] Task 2: Default categories setup (Day 3)
  - CategorySeeder.swift
  - 10 default categories with icons

- [ ] Task 3: Manual Entry form (Days 4-7)
  - Complete form UI
  - Validation logic
  - Save functionality

**Milestone**: Users can add transactions manually

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

### Week 1: Foundation (Current)
- [x] Project setup and architecture
- [ ] Core Data extensions (Transaction & Category work underway)
- [ ] Manual entry form (adds UI & validation once extensions stabilize)

### Week 2: Core Features
- [ ] Transactions list view
- [ ] Dashboard with charts
- [ ] Basic filtering

### Week 3: Polish & Budget
- [ ] Budget management
- [ ] Settings view
- [ ] Data validation

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

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**Harwinder Singh**
- Started: January 2, 2026
- Status: Active Development

## 📞 Support

For questions or issues:
- Create an issue in the GitHub repository
- Review `Progress Tracker.md` and `TODO.md` for the current sprint
- Check `ChangeLog.md` for recent decisions or work items

## 🙏 Acknowledgments

- SwiftUI documentation and community
- Core Data best practices from Apple
- iOS design patterns and guidelines

## 📊 Project Status

**Last Updated**: February 12, 2026

**Current Phase**: Phase 2 - Core Functionality (Manual Entry in progress)

**Next Milestone**: Complete transaction entry experience (Week 1)

**Target MVP Date**: March 4, 2026 (3 weeks from start of development)

---

<p align="center">Made with ❤️ in SwiftUI</p>
