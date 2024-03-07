//
//  ShootModeController.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/6/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import CoreData

class ShootModeController {
    var context: NSManagedObjectContext!
    
    init(context: NSManagedObjectContext!) {
        self.context = context
    }
    
    func resetStatistics(_ game: Game) {
        // Make sure all game stats are zeroed out
        game.team1Score = 0
        game.team1Ones = 0
        game.team1Twos = 0
        game.team1Threes = 0
        game.team1Fours = 0
        game.team1OTMade = 0
        game.team1OTTaken = 0
        game.team2Score = 0
        game.team2Ones = 0
        game.team2Twos = 0
        game.team2Threes = 0
        game.team2Fours = 0
        game.team2OTMade = 0
        game.team2OTTaken = 0
    }
    
    func randomShootingHandProbability(_ game: Game, _ probability: inout Float) -> Bool {
        var hand: Bool
        // Adjust probability to avoid perfection and be out of 1000
        let adjustedProbability = ProbabilityHelper.adjustProbability(&probability)
        // Get a random number up to 1000 to compare to
        let randomNumber = ProbabilityHelper.randomNumberToOneThousand()
        if adjustedProbability >= randomNumber {
            hand = true // true corresponds to right hand
        } else {
            hand = false // false is left hand
        }
        
        // Flip the hand if game.useLeft is true (left-dominant hand)
        if game.useLeft {
            hand = !hand
        }
        
        return hand
    }
    
    func getShootingHands(_ game: Game) {
        var team1Probability, team2Probability: Float
        // Get the game's probability (historical win rate for better seed)
        let gameProbability = ProbabilityHelper.getGameProbability(game)
        // Set team's individual probabilities for use in random number function
        if game.team1Seed < game.team2Seed { // Team 1 is better seed
            team1Probability = gameProbability
            team2Probability = 1 - gameProbability
        } else { // Team 2 is better seed
            team1Probability = 1 - gameProbability
            team2Probability = gameProbability
        }
        // Set the team's output based on a random number generator, separately
        game.team1Hand = randomShootingHandProbability(game, &team1Probability)
        game.team2Hand = randomShootingHandProbability(game, &team2Probability)
    }
    
    func saveRoundScore(game: Game, teamFlag: Bool, count: Int16, scoreMultiplier: Int16) {
        if teamFlag { // team1
            // Add to the score
            game.team1Score += count * scoreMultiplier
            // Use scoreMultiplier to set right stat
            switch scoreMultiplier {
            case 1:
                game.team1Ones = count
            case 2:
                game.team1Twos = count
            case 3:
                game.team1Threes = count
            default: // 4
                game.team1Fours = count
            }
        } else { // team2
            // Add to the score
            game.team2Score += count * scoreMultiplier
            // Use scoreMultiplier to set right stat
            switch scoreMultiplier {
            case 1:
                game.team2Ones = count
            case 2:
                game.team2Twos = count
            case 3:
                game.team2Threes = count
            default: // 4
                game.team2Fours = count
            }
        }
        // Save the round data
        saveData()
    }
    
    func overtimeCheck(_ game: Game) -> Bool {
        return game.team1Score == game.team2Score
    }
    
    private func saveData() {
        SaveHelper.saveData(context, "ShootModeController")
    }
}
