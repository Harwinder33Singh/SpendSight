//
//  NotificationService.swift
//  SpendSight
//
//  Created by Harwinder Singh on 3/20/26.
//

import Foundation
import UserNotifications
import CoreData
import Combine

class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()

    @Published var isAuthorized = false

    override init() {
        super.init()
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
        }
    }

    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Budget Notifications

    func checkBudgetThresholds(for categories: [Category], context: NSManagedObjectContext) {
        guard isAuthorized else { return }

        let calendar = Calendar.current
        let currentMonth = calendar.dateInterval(of: .month, for: Date())!

        for category in categories {
            let budget = category.monthlyBudget
            guard budget > 0 else { continue }

            let spent = category.totalSpent(
                startDate: currentMonth.start,
                endDate: currentMonth.end,
                context: context
            )

            let percentage = spent / budget
            let categoryName = category.name ?? "Unknown Category"

            // Check for 80% threshold
            if percentage >= 0.8 && percentage < 1.0 {
                scheduleNotification(
                    identifier: "budget_80_\(category.id?.uuidString ?? "")",
                    title: "Budget Warning",
                    body: "You've spent 80% of your \(categoryName) budget this month (\(CurrencyService.shared.formatAmount(spent)) of \(CurrencyService.shared.formatAmount(budget)))",
                    category: category
                )
            }

            // Check for 100% threshold
            if percentage >= 1.0 {
                scheduleNotification(
                    identifier: "budget_100_\(category.id?.uuidString ?? "")",
                    title: "Budget Exceeded",
                    body: "You've exceeded your \(categoryName) budget this month (\(CurrencyService.shared.formatAmount(spent)) of \(CurrencyService.shared.formatAmount(budget)))",
                    category: category
                )
            }
        }
    }

    private func scheduleNotification(identifier: String, title: String, body: String, category: Category) {
        // Check if this notification was already sent today
        let todayKey = "notification_\(identifier)_\(Calendar.current.dateComponents([.year, .month, .day], from: Date()))"
        if UserDefaults.standard.bool(forKey: todayKey) {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1

        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                // Mark as sent today
                UserDefaults.standard.set(true, forKey: todayKey)
            }
        }
    }

    // MARK: - General Notifications

    func scheduleRecurringReminder() {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "SpendSight Reminder"
        content.body = "Don't forget to log your expenses today!"
        content.sound = .default

        // Schedule for 7 PM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 19
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func cancelBudgetNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let budgetNotificationIds = requests
                .filter { $0.identifier.hasPrefix("budget_") }
                .map { $0.identifier }

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: budgetNotificationIds)
        }
    }
}

// MARK: - Category Extension for Budget Calculations

extension Category {
    func totalSpent(startDate: Date, endDate: Date, context: NSManagedObjectContext) -> Double {
        let request = Transaction.fetchRequest(
            startDate: startDate,
            endDate: endDate,
            category: self
        )

        do {
            let transactions = try context.fetch(request)
            return transactions
                .filter { $0.amount < 0 } // Only expenses
                .reduce(0) { $0 + abs($1.amount) }
        } catch {
            return 0
        }
    }
}

