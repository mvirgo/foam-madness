//
//  SelectTournamentViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 4/3/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit
import CoreData

class SelectTournamentViewController: UITableViewController {
    // MARK: Variables
    var dataController: DataController!
    var completedTournaments: Bool!
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add a page title
        if completedTournaments {
            navigationItem.title = "Choose a Completed Tournament"
        } else {
            navigationItem.title = "Choose an Existing Tournament"
        }
    }
}
