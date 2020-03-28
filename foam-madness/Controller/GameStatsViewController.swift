//
//  GameStatsViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/27/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit

class GameStatsViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet var team1Stats : [UILabel]!
    @IBOutlet var team2Stats : [UILabel]!
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStats()
    }
    
    // MARK: Other functions
    func loadStats() {
        // TODO: Get actual stats from datastore and replace below
        var exTeam1 : [String] = ["KU", "Right", "100", "50%",
                                  "55%", "35%", "60%", "80%"]
        var exTeam2 : [String] = ["DU", "Left", "55", "30%",
                                  "35%", "40%", "25%", "20%"]
        
        for i in 0...team1Stats!.count-1 {
            team1Stats[i].text = exTeam1[i]
            team2Stats[i].text = exTeam2[i]
        }
    }
    
    // MARK: IBActions
    @IBAction func backToGamesButtonPressed(_ sender: Any) {
        // TODO: Segue should eventually go back to all games view instead of play game
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
}
