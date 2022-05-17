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
    var isSimulated: Bool!
    var brackets: [Dictionary<String, String>] = []
    var chosenBracketFile = ""
    let bracketIndexFile = "bracketIndex"
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add a page title
        navigationItem.title = "Choose a Starting Bracket"
        // Load the bracket index
        let path = Bundle.main.path(forResource: bracketIndexFile, ofType: "plist")!
        brackets = NSArray(contentsOfFile: path) as! [Dictionary<String, String>]
    }
    
    // MARK: Table View functionality
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brackets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bracketCell", for: indexPath)
        // Return in reverse sorted order (more recent years first)
        let bracketText = brackets.reversed()[(indexPath as NSIndexPath).row].first?.value
        
        // Set the cell details
        cell.textLabel?.text = bracketText
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenBracketFile = brackets.reversed()[(indexPath as NSIndexPath).row].first!.key
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
            // And whether or not simulated
            vc.isSimulated = isSimulated
        }
    }
}
