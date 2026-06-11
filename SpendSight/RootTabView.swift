//
//  ContentView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import SwiftUI

struct RootTabView: View {
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie.fill")
                }
            ManualEntryView()
                .tabItem {
                    Label("Add", systemImage: "doc.fill.badge.plus")
                }
            TransactionsView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet.rectangle")
                }
            BudgetsView()
                .tabItem {
                    Label("Budget", systemImage: "target")
                }
            AIAdvisorView(context: context)
                .tabItem {
                    Label("Advisor", systemImage: "sparkles")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    RootTabView()
}
