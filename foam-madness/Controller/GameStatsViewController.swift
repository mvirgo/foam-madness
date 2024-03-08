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
    @IBOutlet weak var overtimePointsLabel: UILabel!
    @IBOutlet weak var overtimeFGPercentageLabel: UILabel!
    @IBOutlet weak var team1OTPoints: UILabel!
    @IBOutlet weak var team1OTPercentage: UILabel!
    @IBOutlet weak var team2OTPoints: UILabel!
    @IBOutlet weak var team2OTPercentage: UILabel!
    
    // MARK: Other variables
    var game: Game!
    
    // MARK: View functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navbar
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load in the game stats
        loadStats()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Re-show the navbar so it's there for other views
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: Other functions
    func loadStats() {
        // Get stats from teams and game
        let stats = GameStatsController().loadStats(game)
        let team1StatsText = stats.team1Stats
        let team2StatsText = stats.team2Stats
        let hasOvertimeStats = stats.hasOvertimeStats
        
        let skip = hasOvertimeStats ? 3 : 1
        for i in 0...team1StatsText.count - skip {
            team1Stats[i].text = team1StatsText[i]
            team2Stats[i].text = team2StatsText[i]
        }
        
        // Add overtime stats if necessary, or else hide
        if hasOvertimeStats {
            // Add OT information to labels
            let overtimeIndex = team1StatsText.count - 2
            team1OTPoints.text = team1StatsText[overtimeIndex]
            team2OTPoints.text = team2StatsText[overtimeIndex]
            team1OTPercentage.text = team1StatsText[overtimeIndex+1]
            team2OTPercentage.text = team1StatsText[overtimeIndex+1]
        } else { // no OT
            // Hide the related labels
            overtimePointsLabel.isHidden = true
            overtimeFGPercentageLabel.isHidden = true
            team1OTPoints.isHidden = true
            team1OTPercentage.isHidden = true
            team2OTPoints.isHidden = true
            team2OTPercentage.isHidden = true
        }
    }
    
    // MARK: IBActions
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
    
}
