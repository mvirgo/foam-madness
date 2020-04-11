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
    
    // View functions
    override func viewDidLoad() {
        print(tournament.games?.count)
    }
}
