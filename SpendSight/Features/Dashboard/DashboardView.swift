//
//  DashboardView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            Text("Dashboard")
                .font(.largeTitle)
                .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    DashboardView()
}
