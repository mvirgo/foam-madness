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
    
    // MARK: Other variables
    var dataController: DataController!
    var game: Game!
    var team1: Team!
    var team2: Team!
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setGameScoreDisplay()
    }
    
    // MARK: Other functions
    func setGameScoreDisplay() {
        team1Name.text = "Kansas"
        team2Name.text = "Duke"
        team1Score.text = "100"
        team2Score.text = "55"
    }
    
    // MARK: IBActions
    @IBAction func seeStatsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showGameStats", sender: nil)
    }
    
    @IBAction func backToGamesButtonPressed(_ sender: Any) {
        // TODO: Segue should eventually go back to all games view instead of play game
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Send data controller to GameStatsViewController
        if let vc = segue.destination as? GameStatsViewController {
            vc.dataController = dataController
        }
    }

}
