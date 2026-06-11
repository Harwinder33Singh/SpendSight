import Foundation
import CoreData

struct FinancialContext: Codable {
    struct BudgetItem: Codable {
        let category: String
        let budget: Double
        let spent: Double
        let percentageUsed: Double
        let isOverBudget: Bool
    }
    struct CategorySpend: Codable {
        let category: String
        let amount: Double
    }
    struct MonthlyAverage: Codable {
        let income: Double
        let expenses: Double
        let netSavings: Double
    }
    struct AccountSummary: Codable {
        let name: String
        let type: String
        let balance: Double
    }

    let currency: String
    let currentMonthSpending: Double
    let currentMonthIncome: Double
    let daysRemainingInMonth: Int
    let budgets: [BudgetItem]
    let topSpendingCategories: [CategorySpend]
    let threeMonthAverage: MonthlyAverage
    let accounts: [AccountSummary]
}

@MainActor
enum AIContextBuilder {
    static func build(context: NSManagedObjectContext) -> FinancialContext {
        let cal = Calendar.current
        let now = Date()

        // Fetch data
        let transactions = (try? context.fetch(Transaction.fetchRequest())) ?? []
        let incomeRecords = (try? context.fetch(Income.fetchRequest())) ?? []
        let categories    = (try? context.fetch(Category.fetchAll())) ?? []
        let accounts      = (try? context.fetch(Account.fetchRequest())) ?? []

        // Month bounds
        let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: now))!
        let nextMonth  = cal.date(byAdding: .month, value: 1, to: monthStart)!

        // Current month spending (real expenses only)
        let monthSpending = transactions
            .filter { $0.isRealExpense && inRange($0.date, monthStart, nextMonth) }
            .reduce(0.0) { $0 + $1.absoluteAmount }

        // Current month income (Income entity + positive transactions)
        let monthIncome = incomeRecords
            .filter { inRange($0.date, monthStart, nextMonth) }
            .reduce(0.0) { $0 + $1.amount }

        // Days remaining
        let daysInMonth   = cal.range(of: .day, in: .month, for: now)?.count ?? 30
        let dayOfMonth    = cal.component(.day, from: now)
        let daysRemaining = max(0, daysInMonth - dayOfMonth)

        // Budget items (categories with budgets, sorted by % used)
        let budgetItems: [FinancialContext.BudgetItem] = categories
            .filter { $0.hasBudget }
            .map { cat in
                let spent  = cat.totalSpentThisMonth()
                let budget = cat.monthlyBudget
                let pct    = budget > 0 ? (spent / budget * 100).rounded() : 0
                return FinancialContext.BudgetItem(
                    category: cat.name ?? "Unknown",
                    budget: budget.rounded(),
                    spent: spent.rounded(),
                    percentageUsed: pct,
                    isOverBudget: cat.isOverBudget()
                )
            }
            .sorted { $0.percentageUsed > $1.percentageUsed }

        // Top 5 spending categories (last 30 days)
        let thirtyDaysAgo = cal.date(byAdding: .day, value: -30, to: now)!
        var catTotals: [String: Double] = [:]
        for tx in transactions where tx.isRealExpense && inRange(tx.date, thirtyDaysAgo, now) {
            let name = tx.category?.name ?? "Other"
            catTotals[name, default: 0] += tx.absoluteAmount
        }
        let topCategories = catTotals
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { FinancialContext.CategorySpend(category: $0.key, amount: $0.value.rounded()) }

        // 3-month average
        var incomes: [Double] = []
        var expenses: [Double] = []
        for offset in 1...3 {
            let mDate  = cal.date(byAdding: .month, value: -offset, to: now)!
            let mStart = cal.date(from: cal.dateComponents([.year, .month], from: mDate))!
            let mEnd   = cal.date(byAdding: .month, value: 1, to: mStart)!

            let inc = incomeRecords
                .filter { inRange($0.date, mStart, mEnd) }
                .reduce(0.0) { $0 + $1.amount }
            let exp = transactions
                .filter { $0.isRealExpense && inRange($0.date, mStart, mEnd) }
                .reduce(0.0) { $0 + $1.absoluteAmount }
            incomes.append(inc)
            expenses.append(exp)
        }
        let avgIncome  = (incomes.reduce(0, +) / 3).rounded()
        let avgExpense = (expenses.reduce(0, +) / 3).rounded()

        // Account summaries
        let accountSummaries = accounts.map { acc in
            FinancialContext.AccountSummary(
                name: acc.name ?? "Account",
                type: acc.type ?? "Checking",
                balance: acc.currentBalance.rounded()
            )
        }

        let currency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD"

        return FinancialContext(
            currency: currency,
            currentMonthSpending: monthSpending.rounded(),
            currentMonthIncome: monthIncome.rounded(),
            daysRemainingInMonth: daysRemaining,
            budgets: budgetItems,
            topSpendingCategories: Array(topCategories),
            threeMonthAverage: FinancialContext.MonthlyAverage(
                income: avgIncome,
                expenses: avgExpense,
                netSavings: (avgIncome - avgExpense).rounded()
            ),
            accounts: accountSummaries
        )
    }

    private static func inRange(_ date: Date?, _ start: Date, _ end: Date) -> Bool {
        guard let d = date else { return false }
        return d >= start && d < end
    }
}
