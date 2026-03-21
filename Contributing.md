# Contributing to SpendSight

Thank you for your interest in contributing to SpendSight! This document provides guidelines and instructions for contributing to the project.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)

**Last Updated**: March 20, 2026

## Code of Conduct

This project follows standard professional conduct:
- Be respectful and constructive
- Focus on what is best for the project
- Show empathy towards other contributors
- Accept constructive criticism gracefully

## Getting Started

### Prerequisites
- macOS 13.0+
- Xcode 15.0+
- Familiarity with SwiftUI and Core Data
- Git installed and configured

### Setup Development Environment

1. **Fork and Clone**
```bash
git clone https://github.com/yourusername/SpendSight.git
cd SpendSight
```

2. **Open in Xcode**
```bash
open SpendSight.xcodeproj
```

3. **Build the Project**
- Select your target device/simulator
- Press `Cmd + B` to build
- Press `Cmd + R` to run

4. **Verify Core Data**
- Run the app
- Check that the database initializes correctly
- Verify no console errors

## Development Workflow

### Branch Strategy

- `main` - Stable, production-ready code
- `feature/*` - Dedicated branch for isolated work on a feature

### Creating a Feature Branch

```bash
git checkout main
git pull origin main
git checkout -b feature/your-feature-name
```

### Working on Your Feature

1. Make small, focused commits
2. Write descriptive commit messages
3. Test your changes thoroughly
4. Keep your branch up to date with main

```bash
git fetch origin
git rebase origin/main
```

## Coding Standards

### Swift Style Guide

Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

#### Naming Conventions

**Variables and Functions**: camelCase
```swift
var transactionAmount: Double
func calculateTotal() -> Double
```

**Types**: PascalCase
```swift
struct Transaction
class CategoryManager
enum PaymentMethod
```

**Constants**: camelCase
```swift
let maximumAmount = 1_000_000.0
let defaultCategory = "Other"
```

#### Code Organization

**Use Extensions for Protocol Conformance**
```swift
// Good
extension Transaction: Identifiable {
    // Identifiable conformance
}

// Avoid
struct Transaction: Identifiable {
    // Mixed concerns in single declaration
}
```

**Group Related Functionality**
```swift
// MARK: - Initialization
// MARK: - Computed Properties
// MARK: - Public Methods
// MARK: - Private Methods
```

#### SwiftUI Best Practices

**Keep Views Small**
```swift
// Good
struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            CategoryIcon(category: transaction.category)
            TransactionDetails(transaction: transaction)
            TransactionAmount(amount: transaction.amount)
        }
    }
}

// Avoid: Large monolithic views
```

**Use Computed Properties for Simple Logic**
```swift
var isOverBudget: Bool {
    spent > budget
}
```

**Prefer @State Over Published When Possible**
```swift
// Good for local state
@State private var selectedCategory: Category?

// Good for shared state
@ObservedObject var viewModel: TransactionViewModel
```

#### Core Data Best Practices

**Always Use Guard Statements**
```swift
// Good
guard let category = transaction.category else {
    return
}

// Avoid
if transaction.category != nil {
    let category = transaction.category! // Never force unwrap
}
```

**Handle Optionals Safely**
```swift
// Good
let amount = transaction.amount ?? 0.0

// Better
guard let amount = transaction.amount else {
    print("Error: Transaction amount is nil")
    return
}
```

**Validation Pattern**
```swift
// Good - use guard-let pattern
guard let title = title?.trimmingCharacters(in: .whitespaces), !title.isEmpty else {
    throw ValidationError.invalidTitle
}

// Avoid - backwards boolean logic
guard ((title?.trimmingCharacters(in: .whitespaces).isEmpty) == nil) else {
    throw ValidationError.invalidTitle  // This is wrong!
}
```

### Documentation

**Document Public APIs**
```swift
/// Creates a new transaction with the specified parameters.
///
/// - Parameters:
///   - amount: The transaction amount (must be > 0)
///   - category: The category for this transaction
///   - date: The date of the transaction
/// - Returns: A new Transaction instance
/// - Throws: ValidationError if parameters are invalid
func createTransaction(amount: Double, category: Category, date: Date) throws -> Transaction
```

**Add Inline Comments for Complex Logic**
```swift
// Calculate the rolling 30-day average, excluding outliers
// that are more than 2 standard deviations from the mean
let average = transactions
    .filter { !$0.isOutlier }
    .map { $0.amount }
    .reduce(0, +) / Double(count)
```

### Testing

**Write Tests for Business Logic**
```swift
func testTransactionValidation() {
    // Given
    let transaction = Transaction()
    transaction.amount = -10.0
    
    // When/Then
    XCTAssertThrowsError(try transaction.validate())
}
```

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

#### Examples

**Good Commits**
```bash
feat(manual-entry): add amount input with currency formatting

- Implemented custom currency text field
- Added real-time formatting as user types
- Included validation for positive amounts

Closes #42
```

```bash
fix(validation): correct Transaction validation guard statements

The validation was using backwards boolean logic with == nil on
the isEmpty property. Changed to proper guard-let pattern.

Fixes #67
```

**Bad Commits**
```bash
# Too vague
"Updated code"

# No context
"Fix bug"

# Multiple unrelated changes
"Add feature, fix bugs, update docs"
```

### Commit Frequency

- Commit early and often
- Each commit should be a logical unit of work
- Commits should not break the build
- Group related changes together

## Pull Request Process

### Before Submitting

1. **Update Your Branch**
```bash
git checkout main
git pull origin main
git checkout your-feature-branch
git rebase main
```

2. **Test Thoroughly**
- [ ] App builds without errors
- [ ] App runs without crashes
- [ ] New feature works as expected
- [ ] Existing features still work
- [ ] No memory leaks (use Instruments)

3. **Review Your Changes**
```bash
git diff main...your-feature-branch
```

4. **Update Documentation**
- [ ] README.md (if needed)
- [ ] TODO.md (check off completed items)
- [ ] ChangeLog.md (add your changes)
- [ ] Progress Tracker.md (if tracking sprint progress)
- [ ] Code comments and documentation

### Creating a Pull Request

1. **Push Your Branch**
```bash
git push origin feature/your-feature-name
```

2. **Open Pull Request on GitHub**
- Go to the repository
- Click "New Pull Request"
- Select `main` as the base branch
- Select your feature branch as the compare branch

3. **Fill Out PR Template**

```markdown
## Description
Brief description of what this PR does

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update
- [ ] Refactoring

## Changes Made
- Fixed Transaction validation logic (lines 181-194)
- Corrected Category sort descriptor naming
- Added proper guard-let patterns

## Testing
- [ ] Tested on iPhone simulator
- [ ] Tested validation with invalid data
- [ ] Manual testing performed

## Bugs Fixed
- Transaction validation boolean logic
- Category sort descriptor typo

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings introduced
- [ ] Tested edge cases

## Related Issues
Fixes #67, Fixes #68
```

4. **Request Review**
- Tag relevant reviewers
- Provide context in comments if needed

### Code Review Process

**As a Reviewer**:
- Be constructive and specific
- Suggest improvements, don't just criticize
- Approve only if you'd be comfortable merging
- Check for:
  - Code quality and style
  - Potential bugs or edge cases
  - Performance implications
  - Security concerns
  - Test coverage

**As an Author**:
- Respond to all comments
- Make requested changes
- Mark conversations as resolved
- Be open to feedback
- Update PR description if scope changes

### Merging

1. **Requirements**
- [ ] All checks passing
- [ ] At least one approval
- [ ] No unresolved conversations
- [ ] Branch is up to date with main

2. **Merge Strategy**
- Use "Squash and Merge" for feature branches
- Use descriptive merge commit message
- Delete branch after merging

## Development Tips

### Debugging Core Data

**View Database Contents**
```bash
# Find the simulator's documents directory
po FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

# Use DB Browser for SQLite to inspect
```

**Enable Core Data Logging**
```bash
# Add to scheme arguments
-com.apple.CoreData.SQLDebug 1
```

### Performance Testing

**Profile with Instruments**
1. Product → Profile (Cmd + I)
2. Choose "Time Profiler" or "Allocations"
3. Record while using the app
4. Analyze hotspots and memory usage

### Common Issues

**Xcode Not Finding Files**
```bash
# Clean build folder
Cmd + Shift + K

# Clean derived data
Cmd + Option + Shift + K

# Restart Xcode
```

**Core Data Migration Issues**
```bash
# Delete app from simulator
# Or: Reset simulator completely
```

## Questions?

If you have questions or need help:
1. Check existing documentation
2. Search closed issues
3. Open a discussion on GitHub
4. Reach out to project maintainers

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

Thank you for contributing to SpendSight! 🎉