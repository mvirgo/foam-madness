//
//  CoreDataTestStack.swift
//  foam-madness-tests
//
//  Created by Michael Virgo on 5/20/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import CoreData

class CoreDataTestStack {
    static let shared = CoreDataTestStack()

    private static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "foam-madness")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return Self.persistentContainer.viewContext
    }
}
