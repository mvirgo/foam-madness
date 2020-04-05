//
//  ShootModeViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/27/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit

class ShootModeViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var shotType: UILabel!
    @IBOutlet weak var handSide: UILabel!
    // Thanks https://stackoverflow.com/questions/50068413/array-of-uibuttons-in-swift-4
    @IBOutlet var boxes : [UIButton]!
    
    // MARK: Other variables
    let overtimeShots: Int16 = 10 // hard-coded number of shots per OT
    var dataController: DataController!
    var game: Game!
    var team1: Team!
    var team2: Team!
    var teamFlag = true // True = Team 1 shooting, False = Team 2 shooting
    var overtimeFlag = false
    var scoreMultiplier: Int16 = 1 // Increment by 1 per shot type
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set ball images based on click state
        boxes.forEach {
            $0.setBackgroundImage(UIImage(named: "basketball-gray"), for: .normal)
            $0.setBackgroundImage(UIImage(named: "basketball"), for: .selected)
        }
        
        // Make sure score and OT stats zeroed out
        game.team1Score = 0
        game.team2Score = 0
        game.team1OTMade = 0
        game.team1OTTaken = 0
        game.team2OTMade = 0
        game.team2OTTaken = 0
        
        // Get shooting hand for each team based on historical results
        getShootingHands()
        
        // Add game date
        game.datePlayed = Date()
        
        // Start the gameplay round
        playRound()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Notify user of hand selections
        if !game.completion {
            let handMessage = "\(team1.name!) shoots " +
                "\(GameHelper.getHandSideString(game.team1Hand))-handed, " +
                "\(team2.name!) shoots " +
            "\(GameHelper.getHandSideString(game.team2Hand))-handed."
            let title = "Shooting Hand"
            alertUser(title: title, message: handMessage, endGame: false)
        }
    }
    
    // MARK: Other functions
    func getGameProbability() -> Float {
        // TODO: Load this elsewhere so don't need to re-load every game?
        let path = Bundle.main.path(forResource: "historicalProbabilities",
                                    ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path)
        
        // Use the team seeds to get the right historical probabilities
        let bestSeed = min(game.team1Seed, game.team2Seed)
        let worstSeed = max(game.team1Seed, game.team2Seed)
        let bestSeedProbabilities = dict!.object(forKey: "\(bestSeed)") as! NSDictionary
        let gameProbability = bestSeedProbabilities.object(forKey: "\(worstSeed)") as! NSNumber
        
        return gameProbability.floatValue
    }
    
    func randomShootingHandProbability(_ probability: inout Float) -> Bool {
        var hand: Bool
        // Adjust probability ever so slightly if 1 or 0 (aka 1v16 probability)
        if probability == 1 {
            probability -= 0.007 // hard-coded probability
        } else if probability == 0 {
            probability += 0.007 // hard-coded probability
        }
        // Adjust probability to be out of 1000
        let adjustedProbability = Int(probability * 1000)
        // Thanks https://stackoverflow.com/questions/26092977/swift-probability-of-random-number-being-selected
        let randomNumber = Int(arc4random_uniform(1000))
        if adjustedProbability >= randomNumber {
            hand = true // true corresponds to right hand
        } else {
            hand = false // false is left hand
        }
        
        return hand
    }
    
    func getShootingHands() {
        var team1Probability, team2Probability: Float
        // Get the game's probability (historical win rate for better seed)
        let gameProbability = getGameProbability()
        // Set team's individual probabilities for use in random number function
        if game.team1Seed < game.team2Seed { // Team 1 is better seed
            team1Probability = gameProbability
            team2Probability = 1 - gameProbability
        } else { // Team 2 is better seed
            team1Probability = 1 - gameProbability
            team2Probability = gameProbability
        }
        // Set the team's output based on a random number generator, separately
        game.team1Hand = randomShootingHandProbability(&team1Probability)
        game.team2Hand = randomShootingHandProbability(&team2Probability)
    }
    
    func playRound() {
        // Make sure all basketballs are unselected
        boxes.forEach {
            $0.isSelected = false
        }
        // Set other display information
        if teamFlag { // first team is playing
            teamName.text = team1.name
            handSide.text = GameHelper.getHandSideString(game.team1Hand)
        } else {
            teamName.text = team2.name
            handSide.text = GameHelper.getHandSideString(game.team2Hand)
        }
        // Set shot type text based on which point shot is being done
        if overtimeFlag {
            shotType.text = "Overtime"
        } else if scoreMultiplier == 1 {
            shotType.text = "\(scoreMultiplier)-point"
        } else {
            shotType.text = "\(scoreMultiplier)-points"
        }
    }
    
    func countShots() -> Int16 {
        // Add up how many balls are selected
        var count: Int16 = 0
        boxes.forEach {
            if $0.isSelected {
                count += 1
            }
        }
        
        return count
    }
    
    func endRound(continueGame: Bool) {
        // Count made shots
        let count = countShots()
        // Add `count` into related team stat
        saveRoundScore(count)
        // Continue game if not finished
        if continueGame {
            // Increment the scoreMultiplier if both teams have gone
            if !teamFlag { // team2 just finished
                scoreMultiplier += 1
            }
            // Flip the team flag
            teamFlag = !teamFlag
            // Play the next round
            playRound()
        }
    }
    
    func saveData() {
        // Save the view context
        do {
            try dataController.viewContext.save()
        } catch {
            print("Failed to save round score.")
        }
    }
    
    func saveRoundScore(_ count: Int16) {
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
    
    func overtimeCheck() -> Bool {
        return game.team1Score == game.team2Score
    }
    
    func playOvertime() {
        // Flip teamFlag
        teamFlag = !teamFlag
        // Play a round
        playRound()
    }
    
    func endOvertimeRound() {
        // Add round points directly to score and update OT stats
        let madeShots = countShots()
        if teamFlag {
            game.team1Score += madeShots
            game.team1OTMade += madeShots
            game.team1OTTaken += overtimeShots
        } else {
            game.team2Score += madeShots
            game.team2OTMade += madeShots
            game.team2OTTaken += overtimeShots
            if !overtimeCheck() { // End the game if no longer tied
                saveData()
                completeGame()
            } else {
                alertUser(title: "More OT", message: "Still Tied! More OT coming.", endGame: false)
            }
        }
        // Play another round if segue wasn't called (i.e. still tied)
        playOvertime()
    }
    
    func alertUser(title: String, message: String, endGame: Bool) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if endGame { // Segue after alert view closed
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "finishGame", sender: nil)
            }))
        } else {
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func addNextGame(_ tournament: Tournament, _ winner: Team, _ winningSeed: Int16) {
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
            let results = TourneyHelper.fetchData(dataController, andPredicate, "Game")
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
        saveData()
    }
    
    func endGameAlert(_ winner: Team) {
        // Set default title and message
        var title = "Game Complete"
        var message = "\(winner.name!) wins the game!"
        // Change the title and message if end of a tournament
        if let tournament = game.tournament {
            if tournament.completion {
                title = "Tournament Complete"
                message = "\(winner.name!) wins the tournament!"
            }
        }
        alertUser(title: title, message: message, endGame: true)
    }
    
    func completeGame() {
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
            addNextGame(tournament, winner, winningSeed)
        }
        // Let the user know the winner
        endGameAlert(winner)
    }
    
    // MARK: IBActions
    @IBAction func ballButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func finishedButtonPressed(_ sender: Any) {
        // Either continue game or finish to game score
        if overtimeFlag {
            endOvertimeRound()
        } else if !teamFlag && scoreMultiplier == 4 { // main game is over
            endRound(continueGame: false)
            // Check whether game needs to continue for overtime
            overtimeFlag = overtimeCheck()
            if overtimeFlag {
                alertUser(title: "Overtime", message: "Tied Up! Going to OT.", endGame: false)
                playOvertime()
            } else { // full game is over
                completeGame()
            }
        } else {
            endRound(continueGame: true)
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Send data controller to GameScoreViewController if that's destination
        if let vc = segue.destination as? GameScoreViewController {
            vc.dataController = dataController
            vc.game = game
        }
    }

}
