//
//  GameHelper.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/29/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import CoreData
import Foundation

class GameHelper {
    static func getHandSideString(_ hand: Bool) -> String {
        let out: String
        if hand {
            out = "Right"
        } else {
            out = "Left"
        }
        return out
    }
    
    static func getRoundString(_ round: Int16) -> String {
        let out: String
        switch round {
        case 0:
            out = "First Four"
        case 1:
            out = "Round of 64"
        case 2:
            out = "Round of 32"
        case 3:
            out = "Sweet Sixteen"
        case 4:
            out = "Elite Eight"
        case 5:
            out = "Final Four"
        case 6:
            out = "Championship"
        default:
            out = ""
        }
        return out
    }
    
    static func getOrderedTeams(_ game: Game) -> [Team] {
        // Hold two teams for use later
        let team1: Team
        let team2: Team
        // Match teams to team ids in game
        let checkTeam = game.teams?.allObjects[0] as! Team
        if checkTeam.id == game.team1Id {
            team1 = checkTeam
            team2 = game.teams?.allObjects[1] as! Team
        } else {
            team1 = game.teams?.allObjects[1] as! Team
            team2 = checkTeam
        }
        
        return [team1, team2]
    }
    
    static func completeGame(_ viewContext: NSManagedObjectContext, _ game: Game,
                             _ team1: Team, _ team2: Team) -> Team {
        // Set game to complete
        game.completion = true
        // Get the winner of this game
        let winner: Team
        let winningSeed: Int16
        if game.team1Score > game.team2Score {
            winner = team1
            winningSeed = game.team1Seed
        } else {
            winner = team2
            winningSeed = game.team2Seed
        }
        // Add the next tourney game, if applicable
        if let tournament = game.tournament {
            TourneyHelper.addNextGame(viewContext, tournament, game, winner, winningSeed)
        }
        
        return winner;
    }
    
    static func createGameExportData(_ game: Game) -> [String: [String: String]] {
        // Create export dictionary for a single game
        var singleGame = [String: String]()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        // All games have round, region and next game
        singleGame = ["Round": String(game.round),
                      "Region": game.region!,
                      "NextGame": String(game.nextGame)]
        // Only add other game stats if complete
        if game.completion {
            singleGame["DatePlayed"] = formatter.string(from: game.datePlayed!)
            let newTeams = GameHelper.getOrderedTeams(game)
            singleGame["Team1"] = newTeams[0].name
            singleGame["Team2"] = newTeams[1].name
            singleGame["Team1Hand"] = GameHelper.getHandSideString(game.team1Hand)
            singleGame["Team2Hand"] = GameHelper.getHandSideString(game.team2Hand)
            singleGame["Team1Seed"] = String(game.team1Seed)
            singleGame["Team2Seed"] = String(game.team2Seed)
            singleGame["Team1Ones"] = String(game.team1Ones)
            singleGame["Team1Twos"] = String(game.team1Twos)
            singleGame["Team1Threes"] = String(game.team1Threes)
            singleGame["Team1Fours"] = String(game.team1Fours)
            singleGame["Team1Score"] = String(game.team1Score)
            singleGame["Team1OTMade"] = String(game.team1OTMade)
            singleGame["Team1OTTaken"] = String(game.team1OTTaken)
            singleGame["Team2Ones"] = String(game.team2Ones)
            singleGame["Team2Twos"] = String(game.team2Twos)
            singleGame["Team2Threes"] = String(game.team2Threes)
            singleGame["Team2Fours"] = String(game.team2Fours)
            singleGame["Team2Score"] = String(game.team2Score)
            singleGame["Team2OTMade"] = String(game.team2OTMade)
            singleGame["Team2OTTaken"] = String(game.team2OTTaken)
        }
        
        return [String(game.tourneyGameId): singleGame]
    }
    
    static func prepareSingleGame(
        _ team1Name: String,
        _ team2Name: String,
        _ reverseTeamDict: [String: [String: String]],
        _ context: NSManagedObjectContext
    ) -> Game {
        // Create a game
        let game = Game(context: context)
        // Hide the region and round from Play Game view
        game.region = ""
        game.round = -1
        // Lookup or create teams
        let team1 = TeamHelper.lookupOrCreateTeam(teamName: team1Name, reverseTeamDict: reverseTeamDict, context: context)
        let team2 = TeamHelper.lookupOrCreateTeam(teamName: team2Name, reverseTeamDict: reverseTeamDict, context: context)
        // Add team ids to game to ensure proper order of score/stats
        game.team1Id = team1.id
        game.team2Id = team2.id
        // Add teams to game
        team1.addToGames(game)
        team2.addToGames(game)
        
        return game
    }
}
