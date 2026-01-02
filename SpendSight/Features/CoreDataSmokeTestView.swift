//
//  CoreDataSmokeTestView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import SwiftUI
import CoreData

struct CoreDataSmokeTestView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)]
    ) private var expenses: FetchedResults<Expense>

    var body: some View {
        VStack(spacing: 16) {
            Text("Expenses count: \(expenses.count)")
                .font(.title3)

            Button("Insert Sample Expense") {
                let e = Expense(context: context)
                e.id = UUID()
                e.title = "Test Coffee"
                e.amount = 4.99
                e.date = Date()
                e.source = "Test"
                e.isRecurring = false

                // Optional fields
                e.merchant = "Starbucks"
                e.notes = nil
                e.rawText = "STARBUCKS 4.99"

                context.saveIfNeeded()
            }
            .buttonStyle(.borderedProminent)

            List(expenses.prefix(10), id: \.objectID) { e in
                VStack(alignment: .leading) {
                    Text(e.title ?? "No title")
                    Text("\(e.amount) • \(e.date ?? Date())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .navigationTitle("Core Data Test")
    }
}
