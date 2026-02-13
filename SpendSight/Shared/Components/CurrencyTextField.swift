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
    // Allow digits and one decimal separator, limit to 2 decimals
    let decimalSeparator = Locale.current.decimalSeparator ?? "."
    var filtered = ""
    var hasSeparator = false
    var decimals = 0
    for c in input {
        if c.isNumber {
            if hasSeparator { decimals += 1}
            if decimals <= 2 { filtered.append(c)}
        } else if String(c) == decimalSeparator && !hasSeparator {
            hasSeparator = true
            filtered.append(c)
        }
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

//// MARK: - Preview
//
//#Preview {
//    struct PreviewWrapper: View {
//        @State private var amount: String = ""
//        @FocusState private var focusedField: ManualEntryView.Field?
//        
//        var body: some View {
//            Form {
//                Section("Amount Entry") {
//                    CurrencyTextField(
//                        title: "Enter amount",
//                        text: $amount,
//                        focusedField: $focusedField
//                    )
//                }
//                
//                Section("Debug") {
//                    Text("Raw Input: '\(amount)'")
//                    if let parsed = parseAmount(amount) {
//                        Text("Parsed: $\(String(format: "%.2f", parsed))")
//                    } else {
//                        Text("Parsed: Invalid")
//                    }
//                }
//            }
//            .onAppear {
//                focusedField = .amount
//            }
//        }
//    }
//    
//    return PreviewWrapper()
//}
