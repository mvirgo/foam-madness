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
    
    static func adjustProbability(_ probability: inout Float) -> Int {
        // Adjust probability ever so slightly if 1 or 0 (aka 1v16 probability)
        if probability == 1 {
            probability -= 0.007 // hard-coded probability
        } else if probability == 0 {
            probability += 0.007 // hard-coded probability
        }
        // Adjust probability to be out of 1000
        return Int(probability * 1000)
    }
    
    static func randomNumberToOneThousand() -> Int {
        // Get a random number up to 1000
        // Thanks https://stackoverflow.com/questions/26092977/swift-probability-of-random-number-being-selected
        return Int(arc4random_uniform(1000))
    }
}
