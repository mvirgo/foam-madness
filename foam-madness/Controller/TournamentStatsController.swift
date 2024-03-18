//
//  TournamentStatsController.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/7/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import CoreData

struct TournamentStatsOutput {
    var totalStatsArray: [Int]
    var leftStatsArray: [Int]
    var rightStatsArray: [Int]
    var hasOvertimeStats: Bool
}

class TournamentStatsController {
    var context: NSManagedObjectContext!
    // Create arrays to hold stats information
    var totalStatsArray = [Int](repeating: 0, count: 11)
    var leftStatsArray = [Int](repeating: 0, count: 11)
    var rightStatsArray = [Int](repeating: 0, count: 11)
    // Create a bunch of variables to add game stats to
    var leftVsLeft = 0, leftVsRight = 0, rightVsRight = 0
    var totalUpsets = 0, leftOverRightUpsets = 0, rightOverLeftUpsets = 0
    var leftBeatsRight = 0, rightBeatsLeft = 0
    var leftPoints = 0, rightPoints = 0
    var leftOnesMade = 0, leftTwosMade = 0, leftThreesMade = 0, leftFoursMade = 0
    var rightOnesMade = 0, rightTwosMade = 0, rightThreesMade = 0, rightFoursMade = 0
    var leftOTMade = 0, leftOTTaken = 0, rightOTMade = 0, rightOTTaken = 0
    
    init(context: NSManagedObjectContext!) {
        self.context = context
    }
    
    // MARK: Public methods
    func getCompletedGames(_ tournament: Tournament) -> [Game] {
        // Get all completed (non-simulated) games in this tournament
        let completionPredicate = NSPredicate(format: "completion == YES")
        let simulatedPredicate = NSPredicate(format: "isSimulated == NO")
        let tourneyPredicate = NSPredicate(format: "tournament == %@", tournament)
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and,
                                               subpredicates: [completionPredicate, simulatedPredicate, tourneyPredicate]
        )
        return TourneyHelper.fetchDataFromContext(context, andPredicate, "Game", []) as! [Game]
    }
    
    func calculateAllStats(_ games: [Game]) -> TournamentStatsOutput {
        // Loop through all games to add their stats
        for game in games {
            checkUpsets(game)
            if game.team1Hand == true && game.team2Hand == true { // Both rights
                rightVsRight += 1
                addTeam1Right(game)
                addTeam2Right(game)
            } else if game.team1Hand == false && game.team2Hand == false { // Both lefts
                leftVsLeft += 1
                addTeam1Left(game)
                addTeam2Left(game)
            } else {
                leftVsRight += 1
                // Add game stats based on hands
                if game.team1Hand == true { // team 1 is right, team 2 is left
                    addTeam1Right(game)
                    addTeam2Left(game)
                    // Update winning percentage
                    if game.team1Score > game.team2Score {
                        rightBeatsLeft += 1
                    } else {
                        leftBeatsRight += 1
                    }
                } else { // team 1 is left, team 2 is right
                    addTeam1Left(game)
                    addTeam2Right(game)
                    // Update winning percentage
                    if game.team1Score > game.team2Score {
                        leftBeatsRight += 1
                    } else {
                        rightBeatsLeft += 1
                    }
                }
            }
        }
        // Set the calculated stats into their arrays
        setStatsArrays(games)
        
        return TournamentStatsOutput(
            totalStatsArray: totalStatsArray,
            leftStatsArray: leftStatsArray,
            rightStatsArray: rightStatsArray,
            hasOvertimeStats: leftOTTaken + rightOTTaken > 0
        )
    }
    
    // MARK: Private methods
    private func checkUpsets(_ game: Game) {
        // Update upsets stats if one occurred
        if game.team1Score > game.team2Score && game.team1Seed > game.team2Seed {
            // Team 1 upset Team 2
            totalUpsets += 1
            if game.team1Hand == true && game.team2Hand == false {
                rightOverLeftUpsets += 1
            } else if game.team1Hand == false && game.team2Hand == true {
                leftOverRightUpsets += 1
            }
        } else if game.team1Score < game.team2Score && game.team1Seed < game.team2Seed {
            // Team 2 upset Team 1
            totalUpsets += 1
            if game.team1Hand == true && game.team2Hand == false {
                leftOverRightUpsets += 1
            } else if game.team1Hand == false && game.team2Hand == true {
                rightOverLeftUpsets += 1
            }
        }
    }
    
   private func addTeam1Right(_ game: Game) {
        // Add team 1 stats for right hand
        rightPoints += Int(game.team1Score)
        rightOnesMade += Int(game.team1Ones)
        rightTwosMade += Int(game.team1Twos)
        rightThreesMade += Int(game.team1Threes)
        rightFoursMade += Int(game.team1Fours)
        rightOTMade += Int(game.team1OTMade)
        rightOTTaken += Int(game.team1OTTaken)
    }
    
    private func addTeam1Left(_ game: Game) {
        // Add team 1 stats for left hand
        leftPoints += Int(game.team1Score)
        leftOnesMade += Int(game.team1Ones)
        leftTwosMade += Int(game.team1Twos)
        leftThreesMade += Int(game.team1Threes)
        leftFoursMade += Int(game.team1Fours)
        leftOTMade += Int(game.team1OTMade)
        leftOTTaken += Int(game.team1OTTaken)
    }
    
    private func addTeam2Right(_ game: Game) {
        // Add team 2 stats for right hand
        rightPoints += Int(game.team2Score)
        rightOnesMade += Int(game.team2Ones)
        rightTwosMade += Int(game.team2Twos)
        rightThreesMade += Int(game.team2Threes)
        rightFoursMade += Int(game.team2Fours)
        rightOTMade += Int(game.team2OTMade)
        rightOTTaken += Int(game.team2OTTaken)
    }
    
    private func addTeam2Left(_ game: Game) {
        // Add team 2 stats for left hand
        leftPoints += Int(game.team2Score)
        leftOnesMade += Int(game.team2Ones)
        leftTwosMade += Int(game.team2Twos)
        leftThreesMade += Int(game.team2Threes)
        leftFoursMade += Int(game.team2Fours)
        leftOTMade += Int(game.team2OTMade)
        leftOTTaken += Int(game.team2OTTaken)
    }
    
    private func setTotalStatsArray(_ games: [Game], _ shotsPerRound: Int) {
        totalStatsArray[0] = games.count // Total games
        totalStatsArray[1] = totalUpsets // Total upsets
        // Note: 2 and 3 are skipped - only relate to hands
        totalStatsArray[4] = (leftPoints + rightPoints) / (games.count * 2) // Pts per game
        // Add up all baskets for total FG%
        let totalLeftMade = leftOnesMade + leftTwosMade + leftThreesMade + leftFoursMade + leftOTMade
        let totalRightMade = rightOnesMade + rightTwosMade + rightThreesMade + rightFoursMade + rightOTMade
        let totalTaken = (games.count * 2 * 40) + leftOTTaken + rightOTTaken
        totalStatsArray[5] = Int((Float(totalLeftMade + totalRightMade) / Float(totalTaken)) * 100) // Total FG%
        totalStatsArray[6] = Int((Float(leftOnesMade + rightOnesMade) / Float(games.count * 2 * shotsPerRound)) * 100) // 1pt%
        totalStatsArray[7] = Int((Float(leftTwosMade + rightTwosMade) / Float(games.count * 2 * shotsPerRound)) * 100) // 2pt%
        totalStatsArray[8] = Int((Float(leftThreesMade + rightThreesMade) / Float(games.count * 2 * shotsPerRound)) * 100) // 3pt%
        totalStatsArray[9] = Int((Float(leftFoursMade + rightFoursMade) / Float(games.count * 2 * shotsPerRound)) * 100) // 4pt%
        if leftOTTaken + rightOTTaken > 0 { // avoid division by zero
            totalStatsArray[10] = Int((Float(leftOTMade + rightOTMade) / Float(leftOTTaken + rightOTTaken)) * 100) // OT%
        }
    }
    
    private func setLeftStatsArray(_ shotsPerRound: Int) {
        let leftGames = leftVsRight + (2 * leftVsLeft)
        if leftGames == 0 {return} // No need to calculate
        leftStatsArray[0] = leftVsRight // Games vs. Opposite
        leftStatsArray[1] = leftOverRightUpsets // Upsets vs. Opposite
        if leftVsRight > 0 { // avoid division by zero
            leftStatsArray[2] = Int((Float(leftBeatsRight) / Float(leftVsRight)) * 100) // Win % vs. Opposite
        }
        leftStatsArray[3] = leftVsLeft // Games vs. Same
        leftStatsArray[4] = leftPoints / leftGames // Pts per game
        // Add up all baskets for total FG%
        let totalLeftMade = leftOnesMade + leftTwosMade + leftThreesMade + leftFoursMade + leftOTMade
        let totalTaken = (leftGames * 40) + leftOTTaken
        leftStatsArray[5] = Int((Float(totalLeftMade) / Float(totalTaken)) * 100) // Total FG%
        leftStatsArray[6] = Int((Float(leftOnesMade) / Float(leftGames * shotsPerRound)) * 100) // 1pt%
        leftStatsArray[7] = Int((Float(leftTwosMade) / Float(leftGames * shotsPerRound)) * 100) // 2pt%
        leftStatsArray[8] = Int((Float(leftThreesMade) / Float(leftGames * shotsPerRound)) * 100) // 3pt%
        leftStatsArray[9] = Int((Float(leftFoursMade) / Float(leftGames * shotsPerRound)) * 100) // 4pt%
        if leftOTTaken > 0 { // avoid division by zero
            leftStatsArray[10] = Int((Float(leftOTMade) / Float(leftOTTaken)) * 100) // OT%
        }
    }
    
    private func setRightStatsArray(_ shotsPerRound: Int) {
        let rightGames = leftVsRight + (2 * rightVsRight)
        if rightGames == 0 {return} // No need to calculate
        rightStatsArray[0] = leftVsRight // Games vs. Opposite
        rightStatsArray[1] = rightOverLeftUpsets // Upsets vs. Opposite
        if leftVsRight > 0 { // avoid division by zero
            rightStatsArray[2] = Int((Float(rightBeatsLeft) / Float(leftVsRight)) * 100) // Win % vs. Opposite
        }
        rightStatsArray[3] = rightVsRight // Games vs. Same
        rightStatsArray[4] = rightPoints / rightGames // Pts per game
        // Add up all baskets for total FG%
        let totalRightMade = rightOnesMade + rightTwosMade + rightThreesMade + rightFoursMade + rightOTMade
        let totalTaken = (rightGames * 40) + rightOTTaken
        rightStatsArray[5] = Int((Float(totalRightMade) / Float(totalTaken)) * 100) // Total FG%
        rightStatsArray[6] = Int((Float(rightOnesMade) / Float(rightGames * shotsPerRound)) * 100) // 1pt%
        rightStatsArray[7] = Int((Float(rightTwosMade) / Float(rightGames * shotsPerRound)) * 100) // 2pt%
        rightStatsArray[8] = Int((Float(rightThreesMade) / Float(rightGames * shotsPerRound)) * 100) // 3pt%
        rightStatsArray[9] = Int((Float(rightFoursMade) / Float(rightGames * shotsPerRound)) * 100) // 4pt%
        if rightOTTaken > 0 { // avoid division by zero
            rightStatsArray[10] = Int((Float(rightOTMade) / Float(rightOTTaken)) * 100) // OT%
        }
    }
    
    private func setStatsArrays(_ games: [Game]) {
        let shotsPerRound = Int(games[0].shotsPerRound)
        // Set all three stats arrays
        setTotalStatsArray(games, shotsPerRound)
        setLeftStatsArray(shotsPerRound)
        setRightStatsArray(shotsPerRound)
    }
}
