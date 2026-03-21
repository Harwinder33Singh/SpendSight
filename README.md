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

### Current (Phase 1–2) ✅
- [x] Core Data model with **6** entities (including `UserProfile` for onboarding and preferences)
- [x] Tab-based navigation (`RootTabView`: Dashboard, Manual Entry, Transactions, Budgets, Settings)
- [x] Persistence layer (`PersistenceController` with load-error handling and `DatabaseErrorView`)
- [x] `AppCoordinator`: loading → onboarding → main (or failed if Core Data cannot load)
- [x] Onboarding flow with profile, category selection, accounts, and `UserProfile` creation
- [x] Default categories: created from onboarding selections (see `OnboardingViewModel`); `CategorySeeder` helpers remain for flags / tooling
- [x] Manual transaction entry (`ManualEntryView` and supporting pickers/components)
- [x] **Transactions** list: grouped by date, search, filter sheet, swipe edit/delete, detail navigation (`TransactionsView` + `TransactionsViewModel`)
- [x] **Dashboard**: summary cards, Swift Charts (top categories + 30-day trend), floating add button (`DashboardView` + `DashboardViewModel`)
- [x] **Budgets**: overview, active budgets, add/detail flows (`BudgetsView`, `AddBudgetView`, `BudgetDetailView`)
- [x] **Settings**: profile, category/account management sheets, data/support sections (`SettingsView`)

### In Development / Polish 🚧
- [ ] Automated tests (unit + UI)
- [ ] Performance pass on large transaction sets
- [ ] Accessibility and localization review
- [ ] Optional: export/backup flows beyond current settings placeholders

### Planned (Phase 3+) 📅
- [ ] Receipt scanning with Vision framework
- [ ] Bank integration via Plaid API
- [ ] Recurring transaction automation (beyond basic flag)
- [ ] Home Screen widgets
- [ ] iCloud sync
- [ ] CSV import/export
- [ ] Advanced analytics

## 🏗 Architecture

### Project Structure

```
SpendSight/
├── App/
│   ├── SpendSightApp.swift           # @main, coordinator, managed object context
│   └── TrackSpendture.xcdatamodeld   # Core Data model
├── Managers/
│   └── AppCoordinator.swift          # AppState: loading / onboarding / main / failed
├── Models/
│   ├── PersistenceController.swift   # NSPersistentContainer, loadError
│   ├── CoreData+Save.swift
│   ├── Extensions/                   # Entity helpers (fetch, validation, formatting)
│   └── Utilities/
│       └── CategorySeeder.swift
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── TransactionsViewModel.swift
│   └── OnboardingViewModel.swift
├── Views/
│   ├── Onboarding/                   # OnboardingView, steps, AddAccountSheet
│   └── Features/
│       ├── Budgets/
│       ├── Dashboard/                # Charts components
│       ├── ManualEntry/
│       ├── Settings/
│       └── Transactions/             # Rows, filters, edit/detail
└── RootTabView.swift                 # Main tab bar
```

### Data Model

#### Core Entities

**Transaction** — Expenses; links to `Category` and `Account`; recurring flag; timestamps.

**Category** — Name, icon, color hex, optional monthly budget.

**Account** — Payment sources; institution metadata.

**Income** — Income entries linked to `Account`.

**SavingsPlan** — Goal tracking (target / current / month).

**UserProfile** — Onboarding completion, name, currency, optional contact fields, profile image data.

### Technology Stack

- **UI**: SwiftUI
- **Persistence**: Core Data (`TrackSpendture` model)
- **Charts**: Swift Charts
- **Pattern**: MVVM-style view models + SwiftUI views
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
   Select a simulator or device, then **⌘R**.

### First Launch

- Core Data loads via `PersistenceController`; if the store fails to open, `DatabaseErrorView` is shown.
- New users go through **Onboarding** (profile, categories, accounts) before `RootTabView`.
- Returning users skip onboarding when `hasCompletedOnboarding` is set in `UserDefaults`.

## 📖 Usage

### Adding a Transaction
1. Open the **Manual Entry** tab (or use **+** on the Dashboard).
2. Enter amount, date, category, account, and optional details.
3. Save; the transaction appears under **Transactions** and in Dashboard summaries.

### Browsing Transactions
1. Open the **Transactions** tab.
2. Use the search field and **filter** control for date, category, account, and amount range.
3. Swipe for edit/delete, or open a row for details.

### Dashboard & Budgets
- **Dashboard**: Period totals and charts update from stored transactions.
- **Budgets**: Set budgets per category and inspect progress in budget detail views.

### Settings
- Manage categories and accounts from **Settings**; additional sections cover support and (in DEBUG) tooling.

## 🛠 Development

### Documentation sync (March 20, 2026)

Markdown under the repo root was aligned with the **actual** folder layout (`Models/`, `Views/`, `ViewModels/`, `Managers/`), the **six-entity** Core Data model, and implemented **Transactions**, **Dashboard**, **Budgets**, and **Settings** flows.

### Guidelines

- Prefer small SwiftUI views and shared components under `Views/Features/…`.
- Use `@FetchRequest` or view models for Core Data reads; save via `CoreData+Save` patterns where used.
- Avoid force unwraps; handle optional relationships safely.

See [Contributing.md](Contributing.md) for branch workflow and commit style.

## 📝 Roadmap

- **Done (high level)**: Data model, onboarding, manual entry, transactions UX, dashboard charts, budgets shell, settings management surfaces.
- **Next**: Tests, polish, export/backup hardening, then Phase 3 features (widgets, sync, etc.).

## 🤝 Contributing

Fork, branch, and open a PR. Details: [Contributing.md](Contributing.md).

## 📄 License

MIT License — add a `LICENSE` file at the repository root when publishing if not already present.

## 👤 Author

**Harwinder Singh**  
Project started January 2, 2026.

## 📞 Support

- Open an issue on GitHub.
- [Progress Tracker.md](Progress%20Tracker.md) — sprint-style progress notes.
- [TODO.md](TODO.md) — task checklist.
- [ChangeLog.md](ChangeLog.md) — notable changes.

## 🙏 Acknowledgments

- Apple SwiftUI, Core Data, and Swift Charts documentation and samples.

## 📊 Project Status

**Last Updated**: March 20, 2026  

**Current Phase**: Phase 2 — core screens implemented; polish and tests ongoing.  

**Latest documentation pass**: Root `.md` files synced to match the codebase layout and features.

---

<p align="center">Made with ❤️ in SwiftUI</p>
