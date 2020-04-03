//
//  BracketCreationViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 4/1/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit
import CoreData

class BracketCreationViewController: UIViewController {
    // MARK: IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    // MARK: Other variables
    var dataController: DataController!
    var bracketLocation: String!
    var regionSeedTeams = [String: [String: Int16]]()
    
    // MARK: View functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navbar
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Start motion on activity indicator
        activityIndicator.startAnimating()
        // Load the bracket
        loadBracket()
        // TODO: Create any teams that aren't created yet
        // TODO: Create all games and add to tourney
        // TODO: Ask user for name of the tournament
        // TODO: Segue to table view of all playable games
        // End activity indicator motion
        activityIndicator.stopAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Re-show the navbar so it's there for other views
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: Other functions
    func loadBracket() {
        // Update taskLabel for current task
        taskLabel.text = "Loading bracket..."
        // Load in bracket
        let path = Bundle.main.path(forResource: bracketLocation, ofType: "plist")!
        regionSeedTeams = NSDictionary(contentsOfFile: path)!.value(forKey: "Regions") as! Dictionary<String, [String: Int16]>
        // Update progress bar to 5%
        progressBar.progress = 0.05
    }
}
