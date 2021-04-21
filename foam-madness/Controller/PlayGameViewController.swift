//
//  PlayGameViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/27/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit
import CoreData

class PlayGameViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var team1: UILabel!
    @IBOutlet weak var team2: UILabel!
    @IBOutlet weak var region: UILabel!
    @IBOutlet weak var round: UILabel!
    @IBOutlet weak var simGameButton: UIButton!
    
    // MARK: Other variables
    var dataController: DataController!
    var game: Game!
    var teams: [Team]!

    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setTeamNames()
        setRegion()
        setRound()
        setSimAvailability()
    }
    
    // MARK: Other functions
    func setTeamNames() {
        let gameTeams = game.teams?.allObjects as! [Team]
        // Ensure proper order of teams
        if gameTeams[0].id == game.team1Id {
            teams = gameTeams
        } else {
            teams = [gameTeams[1], gameTeams[0]]
        }
        // Show seed depending on if game is in a tourney
        if let _ = game.tournament {
            team1.text = String(game.team1Seed) + " - " + teams[0].name!
            team2.text = String(game.team2Seed) + " - " + teams[1].name!
        } else {
            team1.text = teams[0].name!
            team2.text = teams[1].name!
        }
    }
    
    func setRegion() {
        region.text = game.region
    }
    
    func setRound() {
        round.text = GameHelper.getRoundString(game.round)
    }
    
    func setSimAvailability() {
        // Hide or show sim button depending on if in a tournament
        // Currently hides for non-tourney game, since considered equivalent
        //   when playing a single game
        if let _ = game.tournament {
            simGameButton.isHidden = false
        } else {
            simGameButton.isHidden = true
        }
    }

    // MARK: IBActions
    @IBAction func playGamePressed(_ sender: Any) {
        performSegue(withIdentifier: "playGame", sender: nil)
    }
    
    @IBAction func simGamePressed(_ sender: Any) {
        performSegue(withIdentifier: "simGame", sender: nil)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Send data controller to ShootModeViewController
        if let vc = segue.destination as? ShootModeViewController {
            vc.dataController = dataController
            vc.game = game
            vc.team1 = teams[0]
            vc.team2 = teams[1]
            // Set simulated and menu bar based on which segue selected
            if segue.identifier == "playGame" {
                vc.isSimulated = false;
                // Change navbar text during game to "Exit Game" instead of "Back"
                // Thanks https://stackoverflow.com/questions/28471164/how-to-set-back-button-text-in-swift/52968625
                navigationItem.backBarButtonItem = UIBarButtonItem(
                    title: "Exit Game", style: .plain, target: nil, action: nil)
            } else if segue.identifier == "simGame" {
                vc.isSimulated = true;
            }
        }
    }
    
}

