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
    
    // MARK: Other variables
    var dataController: DataController!
    var game: Game!
    var team1: Team!
    var team2: Team!
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStats()
    }
    
    // MARK: Other functions
    func loadStats() {
        // Get stats from teams and game
        var exTeam1 : [String] = [team1.abbreviation!,
                                  GameHelper.getHandSideString(game.team1Hand),
                                  String(game.team1Score)]
        exTeam1 += calcFGPercent([game.team1Ones, game.team1Twos,
                                  game.team1Threes, game.team1Fours])
        var exTeam2 : [String] = [team2.abbreviation!,
                                  GameHelper.getHandSideString(game.team2Hand),
                                  String(game.team2Score)]
        exTeam2 += calcFGPercent([game.team2Ones, game.team2Twos,
                                  game.team2Threes, game.team2Fours])
        
        for i in 0...team1Stats!.count-1 {
            team1Stats[i].text = exTeam1[i]
            team2Stats[i].text = exTeam2[i]
        }
    }
    
    func calcFGPercent(_ shotCounts: [Int16]) -> [String] {
        var out: [String] = []
        let shots: Float = 10 // hard-coded number of shots per round
        var totalMade: Int16 = 0 // counter for total FG%
        
        // Loop through shotCounts and calculate related FG%
        for shotType in shotCounts {
            totalMade += shotType
            let percentage = Int((Float(shotType) / shots) * 100) // round to nearest int
            out.append(String(percentage)+"%")
        }
        
        // Add total FG% at start of out array
        let totalPercentage = Int((Float(totalMade) / (shots * 4)) * 100)
        out = [String(totalPercentage)+"%"] + out
        
        return out
    }
    
    // MARK: IBActions
    @IBAction func backToGamesButtonPressed(_ sender: Any) {
        // TODO: Segue should eventually go back to all games view instead of play game
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
}
