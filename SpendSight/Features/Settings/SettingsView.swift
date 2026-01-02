//
//  SettingsView.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Text("Settings")
                .font(.largeTitle)
                .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
