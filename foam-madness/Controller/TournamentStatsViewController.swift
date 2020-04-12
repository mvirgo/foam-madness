//
//  TournamentStatsViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 4/10/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit
import CoreData

class TournamentStatsViewController: UIViewController {
    // MARK: Variables
    var dataController: DataController!
    var tournament: Tournament!
    var games = [Game]()
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
    
    // MARK: View functions
    override func viewDidLoad() {
        // Get tourney games completed so far
        getCompletedGames()
        // Calculate stats by total, left and right hands
        if games.count > 0 { // Leave stats at zero if nothing played yet
            calculateAllStats()
        }
        // TODO: Display the calculated stats
        print(totalStatsArray)
        print(leftStatsArray)
        print(rightStatsArray)
    }
    
    // MARK: Other functions
    func getCompletedGames() {
        // Get all completed games in this tournament
        let completionPredicate = NSPredicate(format: "completion == YES")
        let tourneyPredicate = NSPredicate(format: "tournament == %@", tournament)
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [completionPredicate, tourneyPredicate])
        games = TourneyHelper.fetchData(dataController, andPredicate, "Game") as! [Game]
    }
    
    func checkUpsets(_ game: Game) {
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
    
    func addTeam1Right(_ game: Game) {
        // Add team 1 stats for right hand
        rightPoints += Int(game.team1Score)
        rightOnesMade += Int(game.team1Ones)
        rightTwosMade += Int(game.team1Twos)
        rightThreesMade += Int(game.team1Threes)
        rightFoursMade += Int(game.team1Fours)
        rightOTMade += Int(game.team1OTMade)
        rightOTTaken += Int(game.team1OTTaken)
    }
    
    func addTeam1Left(_ game: Game) {
        // Add team 1 stats for left hand
        leftPoints += Int(game.team1Score)
        leftOnesMade += Int(game.team1Ones)
        leftTwosMade += Int(game.team1Twos)
        leftThreesMade += Int(game.team1Threes)
        leftFoursMade += Int(game.team1Fours)
        leftOTMade += Int(game.team1OTMade)
        leftOTTaken += Int(game.team1OTTaken)
    }
    
    func addTeam2Right(_ game: Game) {
        // Add team 2 stats for right hand
        rightPoints += Int(game.team2Score)
        rightOnesMade += Int(game.team2Ones)
        rightTwosMade += Int(game.team2Twos)
        rightThreesMade += Int(game.team2Threes)
        rightFoursMade += Int(game.team2Fours)
        rightOTMade += Int(game.team2OTMade)
        rightOTTaken += Int(game.team2OTTaken)
    }
    
    func addTeam2Left(_ game: Game) {
        // Add team 2 stats for left hand
        leftPoints += Int(game.team2Score)
        leftOnesMade += Int(game.team2Ones)
        leftTwosMade += Int(game.team2Twos)
        leftThreesMade += Int(game.team2Threes)
        leftFoursMade += Int(game.team2Fours)
        leftOTMade += Int(game.team2OTMade)
        leftOTTaken += Int(game.team2OTTaken)
    }
    
    func setTotalStatsArray() {
        totalStatsArray[0] = games.count // Total games
        totalStatsArray[1] = totalUpsets // Total upsets
        // Note: 2 and 3 are skipped - only relate to hands
        totalStatsArray[4] = (leftPoints + rightPoints) / games.count // Pts per game
        // Add up all baskets for total FG%
        let totalLeftMade = leftOnesMade + leftTwosMade + leftThreesMade + leftFoursMade + leftOTMade
        let totalRightMade = rightOnesMade + rightTwosMade + rightThreesMade + rightFoursMade + rightOTMade
        let totalTaken = (games.count * 2 * 40) + leftOTTaken + rightOTTaken
        totalStatsArray[5] = Int((Float(totalLeftMade + totalRightMade) / Float(totalTaken)) * 100) // Total FG%
        totalStatsArray[6] = Int((Float(leftOnesMade + rightOnesMade) / Float(games.count * 2 * 10)) * 100) // 1pt%
        totalStatsArray[7] = Int((Float(leftTwosMade + rightTwosMade) / Float(games.count * 2 * 10)) * 100) // 2pt%
        totalStatsArray[8] = Int((Float(leftThreesMade + rightThreesMade) / Float(games.count * 2 * 10)) * 100) // 3pt%
        totalStatsArray[9] = Int((Float(leftFoursMade + rightFoursMade) / Float(games.count * 2 * 10)) * 100) // 4pt%
        if leftOTTaken + rightOTTaken > 0 { // avoid division by zero
            totalStatsArray[10] = Int((Float(leftOTMade + rightOTMade) / Float(leftOTTaken + rightOTTaken)) * 100) // OT%
        }
    }
    
    func setLeftStatsArray() {
        let leftGames = leftVsRight + leftVsLeft
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
        leftStatsArray[6] = Int((Float(leftOnesMade) / Float(leftGames * 10)) * 100) // 1pt%
        leftStatsArray[7] = Int((Float(leftTwosMade) / Float(leftGames * 10)) * 100) // 2pt%
        leftStatsArray[8] = Int((Float(leftThreesMade) / Float(leftGames * 10)) * 100) // 3pt%
        leftStatsArray[9] = Int((Float(leftFoursMade) / Float(leftGames * 10)) * 100) // 4pt%
        if leftOTTaken > 0 { // avoid division by zero
            leftStatsArray[10] = Int((Float(leftOTMade) / Float(leftOTTaken)) * 100) // OT%
        }
    }
    
    func setRightStatsArray() {
        let rightGames = leftVsRight + rightVsRight
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
        rightStatsArray[6] = Int((Float(rightOnesMade) / Float(rightGames * 10)) * 100) // 1pt%
        rightStatsArray[7] = Int((Float(rightTwosMade) / Float(rightGames * 10)) * 100) // 2pt%
        rightStatsArray[8] = Int((Float(rightThreesMade) / Float(rightGames * 10)) * 100) // 3pt%
        rightStatsArray[9] = Int((Float(rightFoursMade) / Float(rightGames * 10)) * 100) // 4pt%
        if rightOTTaken > 0 { // avoid division by zero
            rightStatsArray[10] = Int((Float(rightOTMade) / Float(rightOTTaken)) * 100) // OT%
        }
    }
    
    func setStatsArrays() {
        // Set all three stats arrays
        setTotalStatsArray()
        setLeftStatsArray()
        setRightStatsArray()
    }
    
    func calculateAllStats() {
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
        } // End games for loop
        // Set the calculated stats into their arrays
        setStatsArrays()
    }
}
