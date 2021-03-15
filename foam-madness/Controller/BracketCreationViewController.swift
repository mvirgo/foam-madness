//
//  BracketCreationViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 4/1/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit
import CoreData

class BracketCreationViewController: UIViewController, UITextFieldDelegate {
    // MARK: IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var tourneyNameTextField: UITextField!
    @IBOutlet weak var createTournamentButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var dominantHandLabel: UILabel!
    @IBOutlet weak var handSwitch: UISwitch!
    
    // MARK: Other variables
    var dataController: DataController!
    var context: NSManagedObjectContext!
    var tournament: Tournament!
    var tournamentName: String!
    var isWomens = false
    var bracketLocation: String!
    var regionOrder = [String]()
    var regionSeedTeams = [String: [String: Int16]]()
    var firstFour = [String: [String: String]]()
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide unneeded progress indictators
        activityIndicator.hidesWhenStopped = true
        progressBar.isHidden = true
        // Get view context
        context = dataController.viewContext
        // Set text field delegate so keyboard is handled appropriately
        self.tourneyNameTextField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Re-show the navbar so it's there for other views
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Thanks https://stackoverflow.com/questions/24180954/how-to-hide-keyboard-in-swift-on-pressing-return-key
        tourneyNameTextField.resignFirstResponder()
        return false
    }
    
    // MARK: Other functions
    func loadBracket() {
        // Update taskLabel for current task
        taskLabel.text = "Loading bracket..."
        // Load in bracket
        let path = Bundle.main.path(forResource: bracketLocation, ofType: "plist")!
        let bracketDict = NSDictionary(contentsOfFile: path)!
        regionSeedTeams = bracketDict.value(forKey: "Regions") as! Dictionary<String, [String: Int16]>
        // Set up regions in order
        let regionIDs = bracketDict.value(forKey: "RegionIDs") as! Dictionary<String, String>
        regionOrder = [regionIDs["0"], regionIDs["1"], regionIDs["2"], regionIDs["3"]] as! [String]
        // Check if it's a Women's tournament for using correct probabilities
        isWomens = bracketDict.value(forKey: "IsWomens") as! Bool
        // Get First Four data (if men's)
        if !isWomens {
            firstFour = bracketDict.value(forKey: "FirstFour") as! Dictionary<String, [String: String]>
        }
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
        tournament.createdDate = Date()
        tournament.isWomens = isWomens
        // Make sure it is saved
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
    
    func checkLeftHand() -> Bool {
        let leftHand: Bool
        if handSwitch.isOn { // user is right-hand dominant
            leftHand = false
        } else { // user is left-hand dominant
            leftHand = true
        }
        
        return leftHand
    }
    
    func createFirstFour() {
        // Create all four games
        for i in 0...3 {
            let game = Game(context: context)
            let gameInfo = firstFour[String(i)]!
            game.round = 0
            game.region = gameInfo["Region"]
            game.useLeft = checkLeftHand()
            game.isWomens = isWomens
            // Add both team ids and seeds
            game.team1Seed = Int16(gameInfo["Seed"]!)!
            game.team2Seed = Int16(gameInfo["Seed"]!)!
            game.team1Id = regionSeedTeams[game.region!]![gameInfo["Seed"]! + "1"]!
            game.team2Id = regionSeedTeams[game.region!]![gameInfo["Seed"]! + "2"]!
            // Set tourney game id and next game
            game.tourneyGameId = Int16(i)
            game.nextGame = Int16(gameInfo["NextGame"]!)!
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
        // Hold top seeds in order of games to create (for use with ids)
        let topSeeds = [1, 8, 5, 4, 6, 3, 7, 2]
        // Make counter for tourney game id (start at 4 to avoid First Four)
        var gameId = 4
        // Create all 32 first round games, region by region & seed by seed
        for region in regionOrder {
            for i in topSeeds {
                let game = Game(context: context)
                game.round = 1
                game.region = region
                game.useLeft = checkLeftHand()
                game.isWomens = isWomens
                game.team1Seed = Int16(i)
                game.team2Seed = Int16(17-i)
                // Team 2 may not actually exist yet due to First Four
                game.team1Id = regionSeedTeams[region]![String(i)] ?? -1
                game.team2Id = regionSeedTeams[region]![String(17-i)] ?? -1
                // Set tourney game id and next game
                game.tourneyGameId = Int16(gameId)
                game.nextGame = Int16((gameId / 2) + 34)
                gameId += 1
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
    
    func createLaterRounds() {
        let gamesPerRoundPerRegion = [4, 2, 1, 2, 1]
        // Make counter for tourney game id (start at 36 to avoid early rounds)
        var gameId = 36
        // Loop through rounds
        for i in 2...6 {
            if i < 5 { // Before final four
                // Loop through regions
                for region in regionOrder {
                    for _ in 1...gamesPerRoundPerRegion[i-2] {
                        let game = Game(context: context)
                        game.round = Int16(i)
                        game.region = region
                        game.useLeft = checkLeftHand()
                        game.isWomens = isWomens
                        // Set tourney game id and next game
                        game.tourneyGameId = Int16(gameId)
                        game.nextGame = Int16((gameId / 2) + 34)
                        gameId += 1
                        // Add the game to the tournament
                        tournament.addToGames(game)
                        // Save the data
                        saveData()
                    }
                }
            } else { // Final Four or Championship
                for j in 1...gamesPerRoundPerRegion[i-2] {
                    let game = Game(context: context)
                    game.round = Int16(i)
                    game.useLeft = checkLeftHand()
                    game.isWomens = isWomens
                    if i == 5 {
                        game.region = "Final Four"
                        game.tourneyGameId = Int16(63 + j)
                        game.nextGame = 66
                    } else {
                        game.region = "Championship"
                        game.tourneyGameId = 66
                    }
                    // Add the game to the tournament
                    tournament.addToGames(game)
                    // Save the data
                    saveData()
                }
            }
        }
    }
        
    func createTournamentGames() {
        taskLabel.text = "Creating tournament games..."
        // Note: This function is essentially hard-coded for 2020 bracket style
        // Create First Four if Men's tournament
        if !isWomens {
            createFirstFour()
        }
        progressBar.progress += 0.05
        // Create Round 1 with initial teams
        createFirstRound()
        progressBar.progress += 0.40
        // Create Round 2-Championship with no teams
        createLaterRounds()
        progressBar.progress += 0.30
        // Save the data
        saveData()
    }
    
    func checkExistingNames(_ name: String) -> Bool {
        // Return true if no other tournaments named the same
        let predicate = NSPredicate(format: "name == %@", name)
        return TourneyHelper.fetchData(dataController, predicate, "Tournament").count == 0
    }
    
    // MARK: IBActions
    @IBAction func createTournamentButtonPressed(_ sender: Any) {
        // Set the tournament name based on user input
        let name = tourneyNameTextField.text
        if name != "" {
            if checkExistingNames(name!) { // New tourney name
                tournamentName = tourneyNameTextField.text
            } else {
                // Tell user to find a new name
                alertUser(title: "Invalid Name", message: "Tournament name already taken.")
                return
            }
        } else {
            // Tell user to input a name
            alertUser(title: "Invalid Name", message: "Tournament name cannot be blank.")
            return
        }
        // Hide the text field and button
        tourneyNameTextField.isHidden = true
        createTournamentButton.isHidden = true
        // Hide the hand switch and related label
        handSwitch.isHidden = true
        dominantHandLabel.isHidden = true
        // Hide the navbar
        navigationController?.setNavigationBarHidden(true, animated: true)
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
        // Segue to table view of all playable games
        performSegue(withIdentifier: "showNewTourneyGames", sender: nil)
    }
    
    @IBAction func handSwitchClicked(_ sender: Any) {
        if handSwitch.isOn { // right-hand
            dominantHandLabel.text = "Right-Hand Dominant"
        } else { // left-hand
            dominantHandLabel.text = "Left-Hand Dominant"
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Send data controller to Tournament Games Controller
        if let vc = segue.destination as? TournamentGamesViewController {
            vc.dataController = dataController
            vc.tournament = tournament
        }
    }
}
