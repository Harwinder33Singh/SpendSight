//
//  BudgetsView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import SwiftUI

struct BudgetsView: View {
    var body: some View {
        NavigationStack {
            Text("Budgets & Savings")
                .font(.largeTitle)
                .navigationTitle("Budgets")
        }
    }
}

#Preview {
    BudgetsView()
}
