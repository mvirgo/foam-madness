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
    var context: NSManagedObjectContext!
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
        activityIndicator.hidesWhenStopped = true
        // Get view context
        context = dataController.viewContext
        // Load the bracket
        loadBracket()
        // Create any teams that aren't created yet
        createAnyNewTeams()
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
    
    func getExistingTeams() -> [Int16] {
        var existingsIds: [Int16] = []
        // Use a fetch request to get all existing teams
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        // Fetch the results
        let results = try! context.fetch(fetchRequest)
        // Add any existing ids to the array
        for team in results {
            existingsIds.append((team as! Team).id)
        }
        
        return existingsIds
    }
    
    func loadTeams() -> NSDictionary {
        // Load in teams list
        let path = Bundle.main.path(forResource: "teams", ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path)!
        
        return dict
    }
    
    func createAnyNewTeams() {
        // Update the taskLabel
        taskLabel.text = "Adding any new teams..."
        // Start by getting all existing team ids
        let existingIds = getExistingTeams()
        // Add 5% to progress bar
        progressBar.progress += 0.05
        // Load in all teams from teams dict
        let allTeams = loadTeams()
        // Create any teams in bracket not in existingIds
        for key in allTeams.allKeys {
            let stringKey = String(describing: key)
            let teamId = Int16(stringKey)!
            if !existingIds.contains(teamId) {
                // Create the team
                let teamDict = allTeams.value(forKey: stringKey)! as! Dictionary<String, String>
                let team = Team(context: context)
                team.name = teamDict["name"]
                team.abbreviation = teamDict["abbreviation"]
                team.id = teamId
            }
        }
        // Add 10% to progress bar
        progressBar.progress += 0.10
    }
}
