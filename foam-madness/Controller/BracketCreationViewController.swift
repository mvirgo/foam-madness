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
    @IBOutlet weak var tourneyNameTextField: UITextField!
    @IBOutlet weak var createTournamentButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    // MARK: Other variables
    var dataController: DataController!
    var context: NSManagedObjectContext!
    var tournament: Tournament!
    var tournamentName: String!
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
        // Hide unneeded progress indictators
        activityIndicator.hidesWhenStopped = true
        progressBar.isHidden = true
        // Get view context
        context = dataController.viewContext
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
    
    func alertUser(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func saveData() {
        // Save the view context
        do {
            try context.save()
        } catch {
            print("Failed to save.")
        }
    }
    
    func createTournamentObject() {
        // Update the taskLabel
        taskLabel.text = "Creating tournament object..."
        // Create the tournament
        tournament = Tournament(context: context)
        tournament.name = tournamentName!
        saveData()
        // Add 5% to progress bar
        progressBar.progress += 0.05
    }
    
    func fetchTeamById(_ teamIds: [Int16]) -> [Any] {
        // Get both teams from Core Data and add to game
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        let predicate = NSPredicate(format: "id IN %@", teamIds)
        fetchRequest.predicate = predicate
        // Fetch the results
        let results = try! context.fetch(fetchRequest)
        
        return results
    }
    
    func createFirstFour() {
        let regions = ["East","East","East","West"]
        let seeds = [["111", "112"],["121", "122"],
                     ["161", "162"],["161", "162"]]
        // Create all four games
        for i in 0...3 {
            let game = Game(context: context)
            game.round = 0
            game.region = regions[i]
            // Add both team ids and seeds
            game.team1Id = regionSeedTeams[regions[i]]![seeds[i][0]]!
            game.team2Id = regionSeedTeams[regions[i]]![seeds[i][1]]!
            game.team1Seed = Int16(Int(seeds[i][0])! / 10)
            game.team2Seed = Int16(Int(seeds[i][1])! / 10)
            // Fetch the teams by id
            let results = fetchTeamById([game.team1Id, game.team2Id])
            // Add teams to the game
            for team in results {
                (team as! Team).addToGames(game)
            }
            // Add the game to the tournament
            tournament.addToGames(game)
            // Save the data
            saveData()
        }
    }
    
    func createFirstRound() {
        // Create all 32 first round games, region by region & seed by seed
        for region in regionSeedTeams.keys {
            for i in 1...8 {
                let game = Game(context: context)
                game.round = 1
                game.region = region
                game.team1Seed = Int16(i)
                game.team2Seed = Int16(17-i)
                // Team 2 may not actually exist yet due to First Four
                game.team1Id = regionSeedTeams[region]![String(i)] ?? -1
                game.team2Id = regionSeedTeams[region]![String(17-i)] ?? -1
                // Fetch the teams by id
                let results = fetchTeamById([game.team1Id, game.team2Id])
                // Add teams to the game
                for team in results {
                    (team as! Team).addToGames(game)
                }
                // Add the game to the tournament
                tournament.addToGames(game)
                // Save the data
                saveData()
            }
        }
        
    }
        
    func createTournamentGames() {
        // Note: This function is essentially hard-coded for 2020 bracket style
        // Create First Four
        createFirstFour()
        progressBar.progress += 0.05
        // Create Round 1 with initial teams
        createFirstRound()
        progressBar.progress += 0.40
        // TODO: Create Round 2-Championship with no teams
    }
    
    // MARK: IBActions
    @IBAction func createTournamentButtonPressed(_ sender: Any) {
        // Set the tournament name based on user input
        if tourneyNameTextField.text != "" {
            tournamentName = tourneyNameTextField.text
        } else {
            // Tell user to input a name
            alertUser(title: "Invalid Name", message: "Tournament name cannot be blank.")
            return
        }
        // Hide the text field and button
        tourneyNameTextField.isHidden = true
        createTournamentButton.isHidden = true
        // Show the activity indicator and progress bar
        activityIndicator.isHidden = false
        progressBar.isHidden = false
        // Start motion on activity indicator
        activityIndicator.startAnimating()
        // Load the bracket
        loadBracket()
        // Create any teams that aren't created yet
        createAnyNewTeams()
        // Create the tournament
        createTournamentObject()
        // Create all games and add to tourney
        createTournamentGames()
        // End activity indicator motion
        activityIndicator.stopAnimating()
        // TODO: Segue to table view of all playable games
    }
}
