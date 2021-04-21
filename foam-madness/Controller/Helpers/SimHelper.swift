//
//  SimHelper.swift
//  foam-madness
//
//  Created by Michael Virgo on 4/19/21.
//  Copyright © 2021 mvirgo. All rights reserved.
//

import Foundation

class SimHelper {
    static func simSingleGame(_ dataController: DataController, _ game: Game,
                              _ team1: Team, _ team2: Team) {
        // Get the game's probability (historical win rate for better seed)
        var gameProbability = ProbabilityHelper.getGameProbability(game)
        // Adjust the probability to be up to 1000
        let adjustedProbability = ProbabilityHelper.adjustProbability(&gameProbability)
        // Get a random number up to 1000 to compare to for deciding winner
        let randomNumber = ProbabilityHelper.randomNumberToOneThousand()
        // Get which team is better seed
        let bestSeed: String
        if game.team1Seed < game.team2Seed { // team1 is better seed
            bestSeed = "team1"
        } else {
            bestSeed = "team2"
        }
        // High adj probability means likely better seed wins (when > random num)
        let betterSeedWon: Bool
        if adjustedProbability > randomNumber {
            betterSeedWon = true
        } else {
            betterSeedWon = false
        }
        // Set game score based on winner (add one to winner)
        if betterSeedWon {
            if bestSeed == "team1" {
                game.team1Score += 1
            } else {
                game.team2Score += 1
            }
        } else { // worse seed won
            if bestSeed == "team1" {
                game.team2Score += 1
            } else {
                game.team1Score += 1
            }
        }
        // Set game to simulated and complete
        game.isSimulated = true
        game.completion = true
    }
}
