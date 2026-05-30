//
//  AreaTrendChart.swift
//  SpendSight
//
//  Created by Harwinder Singh on 4/20/26.
//
//  Smooth area chart with gradient fill, 7-day moving average overlay,
//  and tap-to-select tooltip. Drop this into Dashboard/ and call it from DashboardView.
//

import SwiftUI
import Charts

struct AreaTrendChart: View {

    let dailyData: [(date: Date, amount: Double)]
    let movingAverage: [(date: Date, average: Double)]

    @State private var rawSelectedDate: Date?

    // Snap selection to the nearest real data point
    private var selectedPoint: (date: Date, amount: Double)? {
        guard let raw = rawSelectedDate else { return nil }
        return dailyData.min(by: {
            abs($0.date.timeIntervalSince(raw)) < abs($1.date.timeIntervalSince(raw))
        })
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if dailyData.isEmpty {
                emptyView
            } else {
                chartView
                    .frame(height: 210)

                legendRow
                    .padding(.top, 12)

                if let point = selectedPoint {
                    tooltip(for: point)
                        .padding(.top, 10)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .animation(.easeInOut(duration: 0.15), value: selectedPoint?.date)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Chart

    private var chartView: some View {
        Chart {
            // ── Gradient area fill ─────────────────────────────────────────
            ForEach(dailyData, id: \.date) { item in
                AreaMark(
                    x: .value("Date", item.date),
                    yStart: .value("Base", 0),
                    yEnd: .value("Spent", item.amount)
                )
                .interpolationMethod(.catmullRom)   // ← smooth bezier curves
                .foregroundStyle(
                    LinearGradient(
                        stops: [
                            .init(color: .blue.opacity(0.65), location: 0),
                            .init(color: .blue.opacity(0.12), location: 1),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            // ── 7-day moving average (dashed) ─────────────────────────────
            ForEach(movingAverage, id: \.date) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("7-day avg", item.average)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.orange)
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
            }

            // ── Selection indicator ─────────────────────────────────────────
            if let point = selectedPoint {
                RuleMark(x: .value("Day", point.date))
                    .foregroundStyle(Color.gray.opacity(0.35))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))

                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Spent", point.amount)
                )
                .foregroundStyle(Color.blue)
                .symbolSize(55)
            }
        }
        .chartXSelection(value: $rawSelectedDate)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) {
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4))
                    .foregroundStyle(Color.gray.opacity(0.2))
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .font(.system(size: 10))
                    .foregroundStyle(Color.secondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { val in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4))
                    .foregroundStyle(Color.gray.opacity(0.2))
                AxisValueLabel {
                    if let v = val.as(Double.self) {
                        Text(CurrencyService.shared.formatAmountWithoutDecimals(v))
                            .font(.system(size: 10))
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Legend

    private var legendRow: some View {
        HStack(spacing: 18) {
            HStack(spacing: 5) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue.opacity(0.4))
                    .frame(width: 20, height: 10)
                Text("Daily spending")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 5) {
                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 4, height: 2)
                    }
                }
                Text("7-day avg")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Tooltip

    private func tooltip(for point: (date: Date, amount: Double)) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(point.date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(CurrencyService.shared.formatAmount(point.amount))
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            Spacer()
            Image(systemName: "calendar")
                .font(.caption)
                .foregroundStyle(.secondary)
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
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("No spending data yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
    }
}
