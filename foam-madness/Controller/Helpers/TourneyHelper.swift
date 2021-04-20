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
    
    static func addNextGame(_ dataController: DataController, _ tournament: Tournament,
                            _ game: Game, _ winner: Team, _ winningSeed: Int16) {
        // Add the next game, if applicable
        if game.nextGame == -1 {
            // Championship game - the tournament is over!
            tournament.completion = true
            tournament.completionDate = Date()
        } else {
            // Get the next game object
            // Thanks https://stackoverflow.com/questions/35265420/multiple-nspredicates-for-nsfetchrequest-in-swift
            let idPredicate = NSPredicate(format: "tourneyGameId == %@", NSNumber(value: game.nextGame))
            let tourneyPredicate = NSPredicate(format: "tournament == %@", tournament)
            let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [idPredicate, tourneyPredicate])
            let results = TourneyHelper.fetchData(dataController, andPredicate, "Game")
            let nextGame = results[0] as! Game
            // Set team id in next game based on its count
            if nextGame.teams!.count == 0 {
                nextGame.team1Id = winner.id
                nextGame.team1Seed = winningSeed
            } else {
                nextGame.team2Id = winner.id
                nextGame.team2Seed = winningSeed
            }
            // Then add the team to the game object
            winner.addToGames(nextGame)
        }
        // Make sure to save
        saveData(dataController)
    }
    
    class func saveData(_ dataController: DataController) {
        // Save the view context
        do {
            try dataController.viewContext.save()
        } catch {
            print("Failed to save tournament data.")
        }
    }
}
