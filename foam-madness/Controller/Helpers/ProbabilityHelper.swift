//
//  ProbabilityHelper.swift
//  foam-madness
//
//  Created by Michael Virgo on 4/19/21.
//  Copyright © 2021 mvirgo. All rights reserved.
//

import Foundation

class ProbabilityHelper {
    static func getGameProbability(_ game: Game) -> Float {
        // Load appropriate probabilities based on Men or Women
        let filename: String
        if game.isWomens {
            filename = "historicalProbabilitiesWomen"
        } else {
            filename = "historicalProbabilities"
        }
        let path = Bundle.main.path(forResource: filename, ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path)
        
        // Use the team seeds to get the right historical probabilities
        let bestSeed = min(game.team1Seed, game.team2Seed)
        let worstSeed = max(game.team1Seed, game.team2Seed)
        let bestSeedProbabilities = dict!.object(forKey: "\(bestSeed)") as! NSDictionary
        let gameProbability = bestSeedProbabilities.object(forKey: "\(worstSeed)") as! NSNumber
        
        return gameProbability.floatValue
    }
}
