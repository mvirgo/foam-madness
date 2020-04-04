//
//  SelectTeamsViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/31/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit
import CoreData

class SelectTeamsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: IBOutlets
    @IBOutlet weak var pickerView: UIPickerView!
    
    // MARK: Other variables
    var dataController: DataController!
    var teams: [[String]] = [[String]]()
    var reverseTeamDict = [String: [String: String]]()
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect pickerView
        // Thanks https://codewithchris.com/uipickerview-example/
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        // Load the teams
        loadTeams()
    }
    
    // Other functions
    func loadTeams() {
        // Load in teams list
        let path = Bundle.main.path(forResource: "teams", ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path)!
        // Add team name to a temporary array
        var tempTeams: [String] = [String]()
        for key in dict.allKeys {
            let name = (dict.value(forKey: key as! String) as! NSDictionary).value(forKey: "name") as? String
            tempTeams.append(name!)
            // Add to reverseTeamDict for lookup of abbreviation/id later
            let abbreviation = (dict.value(forKey: key as! String) as! NSDictionary).value(forKey: "abbreviation") as? String
            reverseTeamDict[name!] = ["id": String(describing: key), "abbreviation": abbreviation!]
        }
        // Sort the temporary array for easy selection
        tempTeams.sort()
        // Make into two columns of same names
        teams = [tempTeams, tempTeams]
    }
    
    func lookupOrCreateTeam(teamName: String, context: NSManagedObjectContext) -> Team {
        let teamId = Int16((reverseTeamDict[teamName]?["id"])!) ?? 0
        let team: Team
        // Use a fetch request to see if teamId already in data
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        let predicate = NSPredicate(format: "id == %@", NSNumber(value: teamId))
        fetchRequest.predicate = predicate
        // Fetch the results
        let results = try! context.fetch(fetchRequest)
        // If results contains anything, just set the team as the result
        if results.count > 0 {
            team = results[0] as! Team
        } else { // create the team
            team = Team(context: context)
            team.name = teamName
            team.abbreviation = reverseTeamDict[teamName]?["abbreviation"]
            team.id = teamId
        }
        
        return team
    }
    
    func alertUser(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: PickerView functions
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return teams[0].count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teams[component][row]
    }
    
    // IBActions
    @IBAction func continueButtonPressed(_ sender: Any) {
        // Only segue if different teams are selected
        if pickerView.selectedRow(inComponent: 0) != pickerView.selectedRow(inComponent: 1) {
            performSegue(withIdentifier: "viewGame", sender: sender)
        } else {
            alertUser(title: "Invalid Teams", message: "Selected teams must be different.")
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get view context
        let managedObjectContext = dataController.viewContext
        // Create a game
        let game = Game(context: managedObjectContext)
        // Hide the region and round from Play Game view
        game.region = ""
        game.round = -1
        // Lookup or create teams
        let team1 = lookupOrCreateTeam(teamName: teams[0][pickerView.selectedRow(inComponent: 0)],
                                       context: managedObjectContext)
        let team2 = lookupOrCreateTeam(teamName: teams[1][pickerView.selectedRow(inComponent: 1)],
                                       context: managedObjectContext)
        // Add team ids to game to ensure proper order of score/stats
        game.team1Id = team1.id
        game.team2Id = team2.id
        // Add teams to game
        team1.addToGames(game)
        team2.addToGames(game)
        // Send data controller to PlayGameViewController
        if let vc = segue.destination as? PlayGameViewController {
            vc.dataController = dataController
            vc.game = game
        }
    }
}
