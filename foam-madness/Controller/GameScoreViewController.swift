//
//  GameScoreViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/27/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit

class GameScoreViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var team1Name: UILabel!
    @IBOutlet weak var team2Name: UILabel!
    @IBOutlet weak var team1Score: UILabel!
    @IBOutlet weak var team2Score: UILabel!
    @IBOutlet weak var gameScoreHeader: UILabel!
    @IBOutlet weak var seeStatsButton: UIButton!
    @IBOutlet weak var backToGamesButton: UIButton!
    
    // MARK: Other variables
    var dataController: DataController!
    var game: Game!
    var team1: Team!
    var team2: Team!
    
    // MARK: View functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navbar
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make sure teams match original order
        let teams = GameHelper.getOrderedTeams(game)
        team1 = teams[0]
        team2 = teams[1]
        // Set the game score display
        setGameScoreDisplay()
        // Set buttons based on sim/non-sim and tourney/single
        setButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Re-show the navbar so it's there for other views
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: Other functions
    func setGameScoreDisplay() {
        // Show seed depending on if game is in a tourney
        if let _ = game.tournament {
            team1Name.text = String(game.team1Seed) + " - " + team1.name!
            team2Name.text = String(game.team2Seed) + " - " + team2.name!
        } else {
            team1Name.text = team1.name!
            team2Name.text = team2.name!
        }
        // Show scores
        team1Score.text = String(game.team1Score)
        team2Score.text = String(game.team2Score)
        // Add OT or Sim to header, if applicable
        if game.team1OTTaken > 0 {
            gameScoreHeader.text = "Final Score - OT"
        } else if game.isSimulated {
            gameScoreHeader.text = "Final Score - Sim"
        } else {
            gameScoreHeader.text = "Final Score"
        }
    }
    
    func setButtons() {
        // Hide stats if simulated - no stats to show
        if game.isSimulated {
            seeStatsButton.isHidden = true;
        } else {
            seeStatsButton.isHidden = false;
        }
        // Change wording based on back to games or to menu if in tourney
        if let _ = game.tournament {
            backToGamesButton.setTitle("Back to Games", for: .normal)
        } else {
            backToGamesButton.setTitle("Back to Menu", for: .normal)
        }
    }
    
    // MARK: IBActions
    @IBAction func seeStatsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showGameStats", sender: nil)
    }
    
    @IBAction func backToGamesButtonPressed(_ sender: Any) {
        // Pop view controllers based on whether in tourney or single game
        // Thanks https://stackoverflow.com/questions/30003814/how-can-i-pop-specific-view-controller-in-swift
        if let _ = game.tournament {
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: TournamentGamesViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                }
            }
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Send data controller to GameStatsViewController
        if let vc = segue.destination as? GameStatsViewController {
            vc.game = game
        }
    }

}
