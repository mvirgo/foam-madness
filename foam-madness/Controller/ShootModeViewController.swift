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
    var shootModeController: ShootModeController!
    var game: Game!
    var team1: Team!
    var team2: Team!
    var isSimulated: Bool!
    var teamFlag = true // True = Team 1 shooting, False = Team 2 shooting
    var overtimeFlag = false
    var scoreMultiplier: Int16 = 1 // Increment by 1 per shot type
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        shootModeController = ShootModeController(context: dataController.viewContext)
        
        // Set ball images based on click state
        boxes.forEach {
            $0.setBackgroundImage(UIImage(named: "basketball-gray"), for: .normal)
            $0.setBackgroundImage(UIImage(named: "basketball"), for: .selected)
        }
        
        // Make sure score and OT stats zeroed out
        shootModeController.resetStatistics(game)
        
        // Add game date
        game.datePlayed = Date()
        
        // Simulate or play game
        if isSimulated {
            // Simulate the game
            simGame()
        } else {
            // Get shooting hand for each team based on historical results
            shootModeController.getShootingHands(game)
            // Start the gameplay round
            playRound()
        }
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
        shootModeController.saveRoundScore(game: game, teamFlag: teamFlag, count: count, scoreMultiplier: scoreMultiplier)
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
        SaveHelper.saveData(dataController.viewContext, "ShootModeViewController")
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
            if !shootModeController.overtimeCheck(game) { // End the game if no longer tied
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
        // Add an addendum if simulated
        if isSimulated {
            message += " (Sim)"
        }
        alertUser(title: title, message: message, endGame: true)
    }
    
    func simGame() {
        SimHelper.simSingleGame(game, team1, team2)
        saveData()
        completeGame()
    }
    
    func completeGame() {
        let winner = GameHelper.completeGame(dataController.viewContext, game, team1, team2)
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
            overtimeFlag = shootModeController.overtimeCheck(game)
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
