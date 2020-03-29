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
    var dataController: DataController!
    var game: Game!
    var team1: Team!
    var team2: Team!
    var teamFlag = true // True = Team 1 shooting, False = Team 2 shooting
    var scoreMultiplier: Int16 = 1 // Increment by 1 per shot type
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set ball images based on click state
        boxes.forEach {
            $0.setBackgroundImage(UIImage(named: "basketball-gray"), for: .normal)
            $0.setBackgroundImage(UIImage(named: "basketball"), for: .selected)
        }
        
        // TODO: Remove below when using unique games
        game.team1Score = 0
        game.team2Score = 0
        
        // TODO: Get shooting hand for each team and replace below
        game.team1Hand = true // right-hand
        game.team2Hand = false // left-hand
        
        // Add game date
        game.datePlayed = Date()
        
        // Start the gameplay round
        playRound()
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
        shotType.text = "\(scoreMultiplier)-points"
    }
    
    func endRound(continueGame: Bool) {
        // Add up how many balls are selected
        var count: Int16 = 0
        boxes.forEach {
            if $0.isSelected {
                count += 1
            }
        }
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
        } else {
            // Set game to complete
            game.completion = true
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
        // Save the view context
        do {
            try dataController.viewContext.save()
        } catch {
            print("Failed to save round score.")
        }
    }
    
    // MARK: IBActions
    @IBAction func ballButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func finishedButtonPressed(_ sender: Any) {
        // Either continue game or finish to game score
        if !teamFlag && scoreMultiplier == 4 { // game is over
            endRound(continueGame: false)
            performSegue(withIdentifier: "finishGame", sender: nil)
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
            vc.team1 = team1
            vc.team2 = team2
        }
    }

}
