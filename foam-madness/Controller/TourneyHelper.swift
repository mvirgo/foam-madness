//
//  TourneyHelper.swift
//  foam-madness
//
//  Created by Michael Virgo on 4/3/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import CoreData

class TourneyHelper {
    static func fetchTournaments(_ dataControl: DataController, _ predicate: NSPredicate) -> [Any] {
        // Get view context
        let context = dataControl.viewContext
        // Get tournaments from Core Data
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tournament")
        fetchRequest.predicate = predicate
        // Fetch the results
        let results = try! context.fetch(fetchRequest)
        
        return results
    }
}
