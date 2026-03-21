//
//  CurrencyTextField.swift
//  SpendSight
//
//  Created by Harwinder Singh on 2/12/26.
//

import SwiftUI

struct CurrencyTextField: View {
    let title: String
    @Binding var text: String
    @FocusState.Binding var focusedField: ManualEntryView.Field?
    var body: some View {
        VStack(alignment: .leading, spacing: 6){
            TextField(title, text: $text)
                .keyboardType(.decimalPad)
                .font(.title2)
                .fontWeight(.medium)
                .focused($focusedField, equals: .amount)
                .onChange(of: text) {_, newValue in
                    text = sanitizeCurrency(input: newValue)
                }
            if let value = parseAmount(text), value > 0 {
                HStack{
                    Text(formattedCurrency(value))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                }
            } else if !text.isEmpty {
                HStack{
                    Text("Invalid Amount")
                        .font(.caption)
                        .foregroundStyle(.red)
                    Spacer()
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: text)
    }
}

private func sanitizeCurrency(input: String) -> String {
    // Allow digits and one decimal separator; limit to 8 integer digits and 2 decimal places.
    // Strips minus signs and any other non-numeric characters so negative amounts are impossible.
    let decimalSeparator = Locale.current.decimalSeparator ?? "."
    let maxIntegerDigits = 8  // caps at 99,999,999
    var filtered = ""
    var hasSeparator = false
    var decimals = 0
    var integers = 0
    for c in input {
        if c.isNumber {
            if hasSeparator {
                decimals += 1
                if decimals <= 2 { filtered.append(c) }
            } else {
                integers += 1
                if integers <= maxIntegerDigits { filtered.append(c) }
            }
        } else if String(c) == decimalSeparator && !hasSeparator {
            hasSeparator = true
            filtered.append(c)
        }
        // All other characters (including '-') are silently dropped.
    }
    return filtered
}

private func parseAmount(_ s: String) -> Double? {
    guard !s.isEmpty else { return nil }
    
    let formatter = NumberFormatter()
    formatter.locale = .current
    formatter.numberStyle = .decimal
    return formatter.number(from: s)?.doubleValue
}

private func formattedCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.locale = .current
    formatter.numberStyle = .currency
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter.string(from: NSNumber(value: value)) ?? "$\(String(format: "%.2f", value))"
}

