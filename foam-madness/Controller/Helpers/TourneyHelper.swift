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
    
    static func fetchDataFromContext(_ context: NSManagedObjectContext, _ predicate: NSPredicate?, _ entity: String, _ sortDescriptors: [NSSortDescriptor]) -> [Any] {
        // Get tournaments from Core Data
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        if (predicate != nil) {
            fetchRequest.predicate = predicate
        }
        if (sortDescriptors.count > 0) {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        // Fetch the results
        let results = try! context.fetch(fetchRequest)
        
        return results
    }
    
    static func addNextGame(_ viewContext: NSManagedObjectContext, _ tournament: Tournament,
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
            let results = TourneyHelper.fetchDataFromContext(viewContext, andPredicate, "Game", [])
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
        SaveHelper.saveData(viewContext, "TourneyHelper")
    }
    
    static func getTourneyGameText(game: Game) -> String {
        let teams = GameHelper.getOrderedTeams(game)
        let team1 = teams[0]
        let team2 = teams[1]
        var gameText = ""
        if game.completion { // game over, show score
            // Make sure winner is shown first
            if game.team1Score > game.team2Score {
                gameText = "\(game.team1Seed) \(team1.name!):  \(game.team1Score), \(game.team2Seed) \(team2.name!):  \(game.team2Score)"
            } else {
                gameText = "\(game.team2Seed) \(team2.name!):  \(game.team2Score), \(game.team1Seed) \(team1.name!):  \(game.team1Score)"
            }
            // Add OT note, if applicable
            if game.team1OTTaken > 0 {
                gameText += " - OT"
            }
            // Add simulated note, if applicable
            if game.isSimulated {
                gameText += " (Sim)"
            }
        } else { // Game is ready to play
            gameText = "\(game.team1Seed) \(team1.name!) vs. \(game.team2Seed) \(team2.name!)"
        }
        
        return gameText
    }
}
