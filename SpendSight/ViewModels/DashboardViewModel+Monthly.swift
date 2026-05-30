//
//  DashboardViewModel+Monthly.swift
//  SpendSight
//
//  Created by Harwinder Singh on 4/20/26.
//
//  Extension that builds MonthlyBarData[] from Transaction + Income fetch results.
//  Add the @FetchRequest for Income in DashboardView, then call monthlyBarData().
//

import Foundation
import CoreData

extension DashboardViewModel {

    /// Builds the last `months` months of income vs expense data for MonthlyBarsChart.
    ///
    /// - Parameters:
    ///   - transactions: All transactions from Core Data (pass `Array(allTransactions)`)
    ///   - incomes: All Income records from Core Data (pass `Array(allIncomes)`)
    ///   - months: How many months to include (default 6)
    func monthlyBarData(
        from transactions: [Transaction],
        incomes: [Income],
        months: Int = 6
    ) -> [MonthlyBarData] {
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"   // "Jan", "Feb", …

        // Build current month's start date, then step back `months` times
        guard let currentMonthStart = calendar.date(
            from: calendar.dateComponents([.year, .month], from: now)
        ) else { return [] }

        return (0..<months).reversed().compactMap { offset -> MonthlyBarData? in
            guard
                let monthStart = calendar.date(byAdding: .month, value: -offset, to: currentMonthStart),
                let monthEnd   = calendar.date(byAdding: .month, value: 1, to: monthStart)
            else { return nil }

            // Expenses: real spending only — excludes credit card payments
            let expense = transactions
                .filter { tx in
                    guard let date = tx.date else { return false }
                    return date >= monthStart && date < monthEnd && tx.isRealExpense
                }
                .reduce(0.0) { $0 + abs($1.amount) }

            // Income from the Income entity
            let incomeFromEntity = incomes
                .filter { inc in
                    guard let date = inc.date else { return false }
                    return date >= monthStart && date < monthEnd
                }
                .reduce(0.0) { $0 + $1.amount }

            // Income from positive-amount transactions (e.g. "Income" category)
            let incomeFromTransactions = transactions
                .filter { tx in
                    guard let date = tx.date else { return false }
                    return date >= monthStart && date < monthEnd && tx.isIncome
                }
                .reduce(0.0) { $0 + $1.amount }

            let totalIncome = incomeFromEntity + incomeFromTransactions

            // Skip months with no activity — avoids showing empty bars for old months
            guard totalIncome > 0 || expense > 0 else { return nil }

            return MonthlyBarData(
                label: formatter.string(from: monthStart),
                month: monthStart,
                income: totalIncome,
                expense: expense
            )
        }
    }
}


// ─────────────────────────────────────────────────────────────────────────────
// INTEGRATION  –  paste these changes into DashboardView.swift
// ─────────────────────────────────────────────────────────────────────────────

/*

// 1. Add an Income fetch request alongside the existing ones:

@FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Income.date, ascending: false)]
) private var allIncomes: FetchedResults<Income>


// 2. Replace the "Spending Trend" VStack block in chartsSection with:

VStack(alignment: .leading, spacing: 12) {
    Text("Spending Trend (30 Days)")
        .font(.title2)
        .fontWeight(.bold)

    AreaTrendChart(
        dailyData: dailySpendingData,
        movingAverage: movingAverageData
    )
}

VStack(alignment: .leading, spacing: 12) {
    Text("Monthly Overview")
        .font(.title2)
        .fontWeight(.bold)

    MonthlyBarsChart(
        data: monthlyBarDataPoints
    )
}


// 3. Add this computed property at the bottom of DashboardView:

private var monthlyBarDataPoints: [MonthlyBarData] {
    viewModel.monthlyBarData(
        from: Array(allTransactions),
        incomes: Array(allIncomes),
        months: 6
    )
}

*/
