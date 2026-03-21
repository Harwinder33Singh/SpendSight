//
//  SpendSightApp.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

//import SwiftUI
//import CoreData
//
//@main
//struct SpendSightApp: App {
//    let persistenceController = PersistenceController.shared
//
//    var body: some Scene {
//        WindowGroup {
//            RootTabView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
//                .onAppear {
//                    CategorySeeder.seedIfNeeded(modelContext: persistenceController.container.viewContext)
//                }
//        }
//    }
//}

import SwiftUI
import CoreData

@main
struct SpendSightApp: App {
    
    // Persistence
    let persistenceController = PersistenceController.shared
    
    // State management
    @StateObject private var coordinator: AppCoordinator
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _coordinator = StateObject(wrappedValue: AppCoordinator(context: context))
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main content based on app state
                switch coordinator.appState {
                case .loading:
                    LoadingView()

                case .onboarding:
                    OnboardingView(context: persistenceController.container.viewContext) {
                        coordinator.completeOnboarding()
                    }
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)

                case .main:
                    RootTabView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .environmentObject(coordinator)

                case .failed(let message):
                    DatabaseErrorView(message: message)
                }
            }
            .onAppear {
                coordinator.checkAppState(coreDataError: persistenceController.loadError)
            }
        }
    }
}

// MARK: - Database Error View

struct DatabaseErrorView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundStyle(.red)

            Text("Unable to Load Data")
                .font(.title2.bold())

            Text("SpendSight could not open its database. Please restart the app. If the problem persists, reinstalling may resolve it.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Text(message)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.blue)
                
                ProgressView()
            }
        }
    }
}
