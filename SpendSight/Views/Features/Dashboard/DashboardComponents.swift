//
//  DashboardComponents.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/19/26.
//

import SwiftUI
import Charts
import CoreData

// MARK: - Summary Card

struct SummaryCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(formatCurrency(amount))
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyService.shared.formatAmountWithoutDecimals(value)
    }
}

// MARK: - Category Spending Chart

struct CategorySpendingChart: View {
    let data: [(category: Category, amount: Double)]
    let viewModel: DashboardViewModel
    
    @State private var selectedAngle: Double?
    @State private var selectedCategoryID: String?
    
    var body: some View {
        VStack(spacing: 16) {
            if data.isEmpty {
                emptyChartView
            } else {
                Chart(data, id: \.category.objectID) { item in
                    SectorMark(
                        angle: .value("Amount", item.amount),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("Category", categoryName(for: item.category)))
                    .opacity(selectedCategoryID == nil || selectedCategoryID == categoryID(for: item.category) ? 1.0 : 0.5)
                }
                .chartForegroundStyleScale(
                    domain: data.map { categoryName(for: $0.category) },
                    range: data.map { colorFromHex($0.category.colorHex ?? "#000000") }
                )
                .chartAngleSelection(value: $selectedAngle)
                .onChange(of: selectedAngle) { _, newValue in
                    selectedCategoryID = categoryID(for: newValue)
                }
                
                colorLegend
                
                if let selectedID = selectedCategoryID,
                   let selected = data.first(where: { categoryID(for: $0.category) == selectedID })?.category {
                    selectedCategoryDetail(selected)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var emptyChartView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            Text("No spending data")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Start adding transactions to see your spending by category")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
    }
    
    private var colorLegend: some View {
        VStack(spacing: 8) {
            Text("Tap a color to view category")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                ForEach(data, id: \.category.objectID) { item in
                    let id = categoryID(for: item.category)
                    let isSelected = selectedCategoryID == id
                    Button {
                        selectedCategoryID = (selectedCategoryID == id) ? nil : id
                        selectedAngle = nil
                    } label: {
                        Circle()
                            .fill(colorFromHex(item.category.colorHex ?? "#000000"))
                            .frame(width: 18, height: 18)
                            .overlay(
                                Circle()
                                    .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 2)
                            )
                            .scaleEffect(isSelected ? 1.1 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(categoryName(for: item.category))
                }
            }
        }
    }
    
    private func selectedCategoryDetail(_ category: Category) -> some View {
        HStack {
            Image(systemName: category.icon ?? "questionmark")
                .foregroundStyle(category.color)
            
            Text(category.name ?? "Unknown")
                .font(.headline)
            
            Spacer()
            
            if let amount = data.first(where: { $0.category.objectID == category.objectID })?.amount {
                Text(formatCurrency(amount))
                    .font(.headline)
                    .foregroundStyle(category.color)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(category.color.opacity(0.1))
        )
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyService.shared.formatAmountWithoutDecimals(value)
    }
    
    private func categoryID(for category: Category) -> String {
        category.objectID.uriRepresentation().absoluteString
    }
    
    private func categoryName(for category: Category) -> String {
        category.name ?? "Unknown"
    }
    
    private func categoryID(for selectedAngle: Double?) -> String? {
        guard let selectedAngle else { return nil }
        
        var cumulative = 0.0
        for (index, item) in data.enumerated() {
            let start = cumulative
            cumulative += item.amount
            let isLast = index == data.count - 1
            if selectedAngle >= start && (selectedAngle < cumulative || (isLast && selectedAngle <= cumulative)) {
                return categoryID(for: item.category)
            }
        }
        
        return nil
    }
}

// MARK: - Spending Trend Chart

struct SpendingTrendChart: View {
    let dailyData: [(date: Date, amount: Double)]
    let movingAverage: [(date: Date, average: Double)]
    
    @State private var selectedDate: Date?
    
    var body: some View {
        VStack(spacing: 16) {
            if dailyData.isEmpty {
                emptyChartView
            } else {
                Chart {
                    // Daily spending bars
                    ForEach(dailyData, id: \.date) { item in
                        BarMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Amount", item.amount)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .opacity(selectedDate == nil || Calendar.current.isDate(item.date, inSameDayAs: selectedDate!) ? 1.0 : 0.5)
                    }
                    
                    // Moving average line
                    ForEach(movingAverage, id: \.date) { item in
                        LineMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Average", item.average)
                        )
                        .foregroundStyle(.orange)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .symbol(Circle().strokeBorder(lineWidth: 2))
                        .symbolSize(30)
                    }
                }
                .chartXSelection(value: $selectedDate)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 5)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                
                if let selectedDate = selectedDate,
                   let selectedData = dailyData.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                    selectedDateDetail(selectedData)
                }
                
                legendView
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var emptyChartView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            Text("No spending data")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(height: 200)
    }
    
    private func selectedDateDetail(_ data: (date: Date, amount: Double)) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(data.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formatCurrency(data.amount))
                    .font(.headline)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
    
    private var legendView: some View {
        HStack(spacing: 20) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 20, height: 12)
                    .cornerRadius(2)
                Text("Daily Spending")
                    .font(.caption)
            }
            
            HStack(spacing: 8) {
                Rectangle()
                    .fill(.orange)
                    .frame(width: 20, height: 2)
                Text("7-Day Average")
                    .font(.caption)
            }
        }
        .padding(.top, 8)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyService.shared.formatAmount(value)
    }
}

// MARK: - Budget Progress Row

struct BudgetProgressRow: View {
    let category: Category
    let progress: (spent: Double, budget: Double, percentage: Double)
    let viewModel: DashboardViewModel
    
    var progressColor: Color {
        if progress.percentage < 80 {
            return .green
        } else if progress.percentage < 100 {
            return .yellow
        } else {
            return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.icon ?? "questionmark")
                    .foregroundStyle(category.color)
                
                Text(category.name ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(formatCurrency(progress.spent)) / \(formatCurrency(progress.budget))")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text("\(formatCurrency(progress.budget - progress.spent)) left")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(
                            width: min(geometry.size.width * CGFloat(progress.percentage / 100), geometry.size.width),
                            height: 8
                        )
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\(Int(progress.percentage))%")
                    .font(.caption)
                    .foregroundStyle(progressColor)
                
                Spacer()
                
                if progress.percentage > 100 {
                    Label("Over budget", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                } else if progress.percentage > 80 {
                    Label("Almost there", systemImage: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return CurrencyService.shared.formatAmountWithoutDecimals(value)
    }
}

// MARK: - Empty Views

struct EmptyBudgetView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            
            Text("No budgets set")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("Set budgets for your categories to track progress")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Helper Functions

private func colorFromHex(_ hex: String) -> Color {
    let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    guard Scanner(string: cleaned).scanHexInt64(&int) else { return .blue }
    
    let a, r, g, b: UInt64
    switch cleaned.count {
    case 6: (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
    case 8: (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default: return .blue
    }
    
    return Color(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
}
