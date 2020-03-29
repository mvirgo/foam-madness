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
    }
    
    // MARK: Other functions
    func setTeamNames() {
        teams = game.teams?.allObjects as? [Team]
        team1.text = String(teams[0].seed) + " - " + teams[0].name!
        team2.text = String(teams[1].seed) + " - " + teams[1].name!
    }
    
    func setRegion() {
        region.text = game.region?.name
    }
    
    func setRound() {
        round.text = GameHelper.getRoundString(game.round)
    }

    // MARK: IBActions
    @IBAction func playGamePressed(_ sender: Any) {
        performSegue(withIdentifier: "playGame", sender: nil)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Send data controller to ShootModeViewController
        if let vc = segue.destination as? ShootModeViewController {
            vc.dataController = dataController
            vc.game = game
            vc.team1 = teams[0]
            vc.team2 = teams[1]
        }
    }
    
}

