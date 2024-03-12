//
//  GameStatsController.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/7/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

struct GameStatsArrays {
    var team1Stats: [String]
    var team2Stats: [String]
    var hasOvertimeStats: Bool
}

class GameStatsController {
    func loadStats(_ game: Game) -> GameStatsArrays {
        // Make sure teams match original order
        let teams = GameHelper.getOrderedTeams(game)
        let team1 = teams[0]
        let team2 = teams[1]
        
        // Get stats from teams and game
        var team1Stats : [String] = [team1.abbreviation!,
                                  GameHelper.getHandSideString(game.team1Hand),
                                  String(game.team1Score)]
        var team2Stats : [String] = [team2.abbreviation!,
                                  GameHelper.getHandSideString(game.team2Hand),
                                  String(game.team2Score)]
        team1Stats += calcFGPercent([
            game.team1Ones,
            game.team1Twos,
            game.team1Threes,
            game.team1Fours
        ])
        team2Stats += calcFGPercent([
            game.team2Ones,
            game.team2Twos,
            game.team2Threes,
            game.team2Fours
        ])

        
        // Add overtime stats if necessary, or else hide
        let hasOvertimeStats = game.team1OTTaken > 0
        if hasOvertimeStats {
            // Add OT information to labels
            team1Stats += [String(game.team1OTMade), shotPercentageString(shotsMade: game.team1OTMade, shotsTaken: (game.team1OTTaken))]
            team2Stats += [String(game.team2OTMade), shotPercentageString(shotsMade: game.team2OTMade, shotsTaken: (game.team2OTTaken))]
        }
        
        return GameStatsArrays(team1Stats: team1Stats, team2Stats: team2Stats, hasOvertimeStats: hasOvertimeStats)
    }
    
    private func calcFGPercent(_ shotCounts: [Int16]) -> [String] {
        var out: [String] = []
        let shots: Int16 = 10 // hard-coded number of shots per round
        var totalMade: Int16 = 0 // counter for total FG%
        
        // Loop through shotCounts and calculate related FG%
        for shotType in shotCounts {
            totalMade += shotType
            out.append(shotPercentageString(shotsMade: shotType, shotsTaken: shots))
        }
        
        // Add total FG% at start of out array
        out = [shotPercentageString(shotsMade: totalMade, shotsTaken: (shots * 4))] + out
        
        return out
    }
    
    private func shotPercentageString(shotsMade: Int16, shotsTaken: Int16) -> String {
        // round to nearest int
        let percentage = Int((Float(shotsMade) / Float(shotsTaken)) * 100.0)
        return "\(percentage)%"
    }
}
