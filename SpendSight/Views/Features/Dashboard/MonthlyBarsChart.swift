//
//  MonthlyBarsChart.swift
//  SpendSight
//
//  Created by Harwinder Singh on 4/20/26.
//
//  Grouped bar chart showing income vs expenses per month for the last N months.
//  Tap any bar group to see the breakdown tooltip. Uses DashboardViewModel.monthlyBarData().
//

import SwiftUI
import Charts

// MARK: - Data Model

struct MonthlyBarData: Identifiable {
    let id = UUID()
    let label: String       // "Jan", "Feb", etc.
    let month: Date         // used for sorting
    let income: Double
    let expense: Double

    var net: Double { income - expense }
}

// MARK: - Chart View

struct MonthlyBarsChart: View {

    let data: [MonthlyBarData]

    @State private var selectedLabel: String?

    private var selected: MonthlyBarData? {
        guard let label = selectedLabel else { return nil }
        return data.first(where: { $0.label == label })
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            summaryRow
                .padding(.bottom, 16)

            if data.isEmpty {
                emptyView
            } else {
                chartView
                    .frame(height: 210)

                legendRow
                    .padding(.top, 12)

                if let point = selected {
                    selectedDetail(point)
                        .padding(.top, 10)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .animation(.easeInOut(duration: 0.15), value: selectedLabel)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Summary Row

    private var summaryRow: some View {
        HStack(spacing: 0) {
            summaryMetric(
                label: "Avg income",
                value: avgIncome,
                color: .blue
            )
            Divider().frame(height: 32)
            summaryMetric(
                label: "Avg spend",
                value: avgExpense,
                color: Color.red.opacity(0.8)
            )
            Divider().frame(height: 32)
            summaryMetric(
                label: "Avg saved",
                value: avgNet,
                color: avgNet >= 0 ? .green : .red
            )
        }
    }

    private func summaryMetric(label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(CurrencyService.shared.formatAmountWithoutDecimals(abs(value)))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Chart

    private var chartView: some View {
        Chart {
            ForEach(data) { point in
                // Income bars (blue)
                BarMark(
                    x: .value("Month", point.label),
                    y: .value("Income", point.income),
                    width: .ratio(0.4)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.65)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(4)
                .position(by: .value("Series", "Income"))
                .opacity(selectedLabel == nil || selectedLabel == point.label ? 1.0 : 0.35)

                // Expense bars (red)
                BarMark(
                    x: .value("Month", point.label),
                    y: .value("Expense", point.expense),
                    width: .ratio(0.4)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red.opacity(0.85), .red.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(4)
                .position(by: .value("Series", "Expense"))
                .opacity(selectedLabel == nil || selectedLabel == point.label ? 1.0 : 0.35)
            }

            // Selection rule
            if let lbl = selectedLabel {
                RuleMark(x: .value("Selected", lbl))
                    .foregroundStyle(Color.gray.opacity(0.25))
                    .lineStyle(StrokeStyle(lineWidth: 1))
            }
        }
        .chartXSelection(value: $selectedLabel)
        .chartXAxis {
            AxisMarks { val in
                AxisValueLabel {
                    if let label = val.as(String.self) {
                        Text(label)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { val in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4))
                    .foregroundStyle(Color.gray.opacity(0.2))
                AxisValueLabel {
                    if let v = val.as(Double.self) {
                        Text(shortCurrency(v))
                            .font(.system(size: 10))
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
        }
        .chartLegend(.hidden)
    }

    // MARK: - Legend

    private var legendRow: some View {
        HStack(spacing: 18) {
            HStack(spacing: 5) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue)
                    .frame(width: 12, height: 12)
                Text("Income")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 5) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.red.opacity(0.8))
                    .frame(width: 12, height: 12)
                Text("Expenses")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Selected Detail Tooltip

    private func selectedDetail(_ point: MonthlyBarData) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(point.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 14) {
                    Label(
                        CurrencyService.shared.formatAmountWithoutDecimals(point.income),
                        systemImage: "arrow.down.circle.fill"
                    )
                    .foregroundStyle(.blue)
                    .font(.caption)

                    Label(
                        CurrencyService.shared.formatAmountWithoutDecimals(point.expense),
                        systemImage: "arrow.up.circle.fill"
                    )
                    .foregroundStyle(.red.opacity(0.85))
                    .font(.caption)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Net")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(CurrencyService.shared.formatAmountWithoutDecimals(point.net))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(point.net >= 0 ? .green : .red)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }

    // MARK: - Empty State

    private var emptyView: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("No data available")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
    }

    // MARK: - Computed Averages

    private var avgIncome: Double {
        guard !data.isEmpty else { return 0 }
        return data.map(\.income).reduce(0, +) / Double(data.count)
    }

    private var avgExpense: Double {
        guard !data.isEmpty else { return 0 }
        return data.map(\.expense).reduce(0, +) / Double(data.count)
    }

    private var avgNet: Double { avgIncome - avgExpense }

    // MARK: - Helpers

    /// Short axis label: "$1.2k" or "$500"
    private func shortCurrency(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "$%.1fk", value / 1000)
        }
        return "$\(Int(value))"
    }
}
