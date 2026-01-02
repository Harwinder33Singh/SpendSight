//
//  TransactionsView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import SwiftUI

struct TransactionsView: View {
    var body: some View {
        NavigationStack {
            Text("Transactions")
                .font(.largeTitle)
                .navigationTitle("Transactions")
        }
    }
}

#Preview {
    TransactionsView()
}
