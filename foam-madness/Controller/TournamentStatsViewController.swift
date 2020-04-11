//
//  TournamentStatsViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 4/10/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit
import CoreData

class TournamentStatsViewController: UIViewController {
    // MARK: Variables
    var dataController: DataController!
    var tournament: Tournament!
    var games = [Game]()
    
    // MARK: View functions
    override func viewDidLoad() {
        // Get tourney games completed so far
        getCompletedGames()
        // TODO: Calculate stats by total, left and right hands
        // TODO: Display the calculated stats
    }
    
    // MARK: Other functions
    func getCompletedGames() {
        // Get all completed games in this tournament
        let completionPredicate = NSPredicate(format: "completion == YES")
        let tourneyPredicate = NSPredicate(format: "tournament == %@", tournament)
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [completionPredicate, tourneyPredicate])
        games = TourneyHelper.fetchData(dataController, andPredicate, "Game") as! [Game]
    }
}
