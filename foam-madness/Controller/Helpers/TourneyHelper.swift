//
//  TourneyHelper.swift
//  foam-madness
//
//  Created by Michael Virgo on 4/3/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import CoreData

class TourneyHelper {
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
        if (game.teams?.count == 0) {
            return "Pending participants"
        } else if (game.teams?.count == 1) {
            let team = (game.teams?.allObjects as! [Team])[0]
            let seed = game.team1Id == team.id ? game.team1Seed : game.team2Seed
            return "\(seed) \(team.name ?? "") vs. Pending participant"
        }
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
    
    // Since the original implementation didn't guarantee team1Id comes from the "top" game
    // of a bracket, we have to find for second round and later which had the "top" previous game
    private static func orderTeamsByPreviousRound(game: Game) -> [Int16] {
        if game.teams?.count == 0 {
            return [-1, -1]
        }
        
        if let tournament = game.tournament {
            let previousGames = tournament.games!.filtered(using: NSPredicate(format: "nextGame == %i", game.tourneyGameId)) as! Set<Game>
            if (previousGames.isEmpty) {
                // May not have previous games for custom brackets with <64 games
                let teams = GameHelper.getOrderedTeams(game)
                return [teams[0].id, teams[1].id]
            }
            let firstPreviousGame = previousGames.min(by: { $0.tourneyGameId < $1.tourneyGameId })!
            
            if game.teams?.count == 1 {
                let teamId = GameHelper.getTeamIdsForGame(game).first!
                if teamId == firstPreviousGame.team1Id || teamId == firstPreviousGame.team2Id {
                    return [teamId, -1]
                }
                return [-1, teamId]
            }
            
            let teamIds = GameHelper.getTeamIdsForGame(game)
            // If teamIds[0] in firstPreviousGame, return it first in order
            if teamIds[0] == firstPreviousGame.team1Id || teamIds[0] == firstPreviousGame.team2Id {
                return [teamIds[0], teamIds[1]]
            }
            return [teamIds[1], teamIds[0]]
        }
        
        return [-1, -1]
    }
    
    private static func createBracketLineText(seed: Int16, team: String, score: Int16, completion: Bool) -> String {
        return "\(seed) \(team)\(completion ? ":  \(score)" : "")"
    }
    
    static func getBracketGameText(game: Game) -> [String] {
        var output: [String] = []
        if game.teams?.count ?? 0 == 0 {
            return ["Pending", "Pending"]
        }
        
        if game.teams?.count == 1 {
            let setTeam = game.teams?.allObjects[0] as! Team
            // Note: Seed will always be team1Seed, since it is set first, regardless of top/bottom bracket part
            output.append(createBracketLineText(seed: game.team1Seed, team: setTeam.abbreviation ?? "", score: 0, completion: game.completion))
            
            if game.round <= 1 {
                // Order will be correct for First Four and Round of 64
                output.append("Pending")
            } else {
                // Need to check previous round
                let teamIds = orderTeamsByPreviousRound(game: game)
                if teamIds[0] == -1 {
                    output.insert("Pending", at: 0)
                } else {
                    output.append("Pending")
                }
            }
            
            return output
        }
        
        let topTeam, bottomTeam: Team
        if game.round <= 1 {
            // Order will be correct for First Four and Round of 64
            let teams = GameHelper.getOrderedTeams(game)
            topTeam = teams[0]
            bottomTeam = teams[1]
        } else {
            let teamIds = orderTeamsByPreviousRound(game: game)
            let teams = game.teams?.allObjects as! [Team]
            if teamIds[0] == teams[0].id {
                topTeam = teams[0]
                bottomTeam = teams[1]
            } else {
                topTeam = teams[1]
                bottomTeam = teams[0]
            }
        }
        
        if (game.team1Id == topTeam.id) {
            output.append(createBracketLineText(seed: game.team1Seed, team: topTeam.abbreviation ?? "", score: game.team1Score, completion: game.completion))
            output.append(createBracketLineText(seed: game.team2Seed, team: bottomTeam.abbreviation ?? "", score: game.team2Score, completion: game.completion))
        } else {
            output.append(createBracketLineText(seed: game.team2Seed, team: topTeam.abbreviation ?? "", score: game.team2Score, completion: game.completion))
            output.append(createBracketLineText(seed: game.team1Seed, team: bottomTeam.abbreviation ?? "", score: game.team1Score, completion: game.completion))
        }
        
        return output
    }
}
