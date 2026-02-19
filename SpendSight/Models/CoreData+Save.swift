//
//  CoreData+Save.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import CoreData

extension NSManagedObjectContext {
    func saveIfNeeded() {
        guard hasChanges else { return }
        do { try save() }
        catch {
            assertionFailure("Core Data save failed: \(error)")
        }
    }
}
