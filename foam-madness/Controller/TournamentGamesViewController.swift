//
//  TournamentGamesViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 4/3/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit
import CoreData

class TournamentGamesViewController: UIViewController {
    // MARK: IBOutlets
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var gameTableView: UITableView!
    @IBOutlet weak var roundStepper: UIStepper!
    
    // MARK: Other variables
    var dataController: DataController!
    var context: NSManagedObjectContext!
    var tournament: Tournament!
}
