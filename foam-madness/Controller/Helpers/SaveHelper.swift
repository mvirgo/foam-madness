//
//  SaveHelper.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/6/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import CoreData

class SaveHelper {
    static func saveData(_ context: NSManagedObjectContext, _ location: String) {
        // Save the view context
        do {
            try context.save()
        } catch {
            print("Failed to save from \(location).")
        }
    }
}
