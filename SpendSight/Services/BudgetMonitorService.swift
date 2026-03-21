//
//  BudgetMonitorService.swift
//  SpendSight
//
//  Created by Harwinder Singh on 3/20/26.
//

import Foundation
import CoreData
import Combine

class BudgetMonitorService: ObservableObject {
    static let shared = BudgetMonitorService()

    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context

        // Monitor for Core Data changes
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.checkAllBudgets()
            }
            .store(in: &cancellables)
    }

    // MARK: - Budget Monitoring

    func checkAllBudgets() {
        context.perform {
            do {
                let categories = try self.context.fetch(Category.fetchRequest())
                let categoriesWithBudgets = categories.filter { ($0.monthlyBudget ?? 0) > 0 }

                DispatchQueue.main.async {
                    NotificationService.shared.checkBudgetThresholds(
                        for: categoriesWithBudgets,
                        context: self.context
                    )
                }
            } catch {
                print("Failed to fetch categories for budget monitoring: \(error)")
            }
        }
    }

    func checkBudgetForCategory(_ category: Category) {
        guard (category.monthlyBudget ?? 0) > 0 else { return }

        context.perform {
            DispatchQueue.main.async {
                NotificationService.shared.checkBudgetThresholds(
                    for: [category],
                    context: self.context
                )
            }
        }
    }

    // MARK: - Manual Budget Check

    func forceCheckAllBudgets() {
        checkAllBudgets()
    }
}