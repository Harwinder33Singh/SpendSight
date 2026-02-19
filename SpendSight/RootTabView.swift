//
//  ContentView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie.fill")
                }
            ManualEntryView()
                .tabItem {
                    Label("Manual Entry", systemImage: "doc.fill.badge.plus")
                }
            TransactionsView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet.rectangle")
                }
            DataDebugView()
                .tabItem {
                    Label("Budget", systemImage: "target")
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
