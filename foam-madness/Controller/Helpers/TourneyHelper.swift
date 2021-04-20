//
//  TourneyHelper.swift
//  foam-madness
//
//  Created by Michael Virgo on 4/3/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import CoreData

class TourneyHelper {
    static func fetchData(_ dataController: DataController, _ predicate: NSPredicate, _ entity: String) -> [Any] {
        // Get view context
        let context = dataController.viewContext
        // Get tournaments from Core Data
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = predicate
        // Fetch the results
        let results = try! context.fetch(fetchRequest)
        
        return results
    }
}
