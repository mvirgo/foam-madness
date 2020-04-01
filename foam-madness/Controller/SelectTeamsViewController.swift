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
        performSegue(withIdentifier: "viewGame", sender: sender)
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
        // TODO: Hide seeds?
        game.team1Seed = 1
        game.team2Seed = 1
        // TODO: Check if teams already exist before creating
        // Create teams
        let team1 = Team(context: managedObjectContext)
        let team2 = Team(context: managedObjectContext)
        team1.name = teams[0][pickerView.selectedRow(inComponent: 0)]
        team2.name = teams[1][pickerView.selectedRow(inComponent: 1)]
        // Get abbreviations
        team1.abbreviation = reverseTeamDict[team1.name!]?["abbreviation"]
        team2.abbreviation = reverseTeamDict[team2.name!]?["abbreviation"]
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
