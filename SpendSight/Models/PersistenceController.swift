//
//  PersistenceController.swift
//  SpendSight
//
//  Created by Harwinder Singh on 1/2/26.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer
    private(set) var loadError: Error?

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TrackSpendture")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        var storeError: Error?
        container.loadPersistentStores { _, error in
            storeError = error
        }
        self.loadError = storeError

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
