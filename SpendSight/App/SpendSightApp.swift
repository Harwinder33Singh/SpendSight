//
//  SpendSightApp.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import SwiftUI
import CoreData

@main
struct SpendSightApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    CategorySeeder.seedIfNeeded(modelContext: persistenceController.container.viewContext)
                }
        }
    }
}
