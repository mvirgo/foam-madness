//
//  CreateTournamentViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 4/1/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit
import CoreData

class SelectInitialBracketViewController: UITableViewController {
    // MARK: Variables
    var dataController: DataController!
    var chosenBracketFile = ""
    let brackets = ["2020 Joe Lunardi's Bracketology": "bracketology2020",
                    "2020 Womens - Charlie Creme's Bracketology": "womensBracketology2020"]
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add a page title
        navigationItem.title = "Choose a Starting Bracket"
    }
    
    // MARK: Table View functionality
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brackets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bracketCell", for: indexPath)
        let bracket = Array(brackets.keys)[(indexPath as NSIndexPath).row]
        
        // Set the cell details
        cell.textLabel?.text = bracket
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bracket = Array(brackets.keys)[(indexPath as NSIndexPath).row]
        chosenBracketFile = brackets[bracket]!
        // Segue to bracket creation screen
        performSegue(withIdentifier: "createBracket", sender: nil)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BracketCreationViewController {
            // Send bracket file location to Bracket Creation View
            vc.bracketLocation = chosenBracketFile
            // Send data controller as well
            vc.dataController = dataController
        }
    }
}
