//
//  CreateTournamentViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 4/1/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit
import CoreData

class CreateTournamentViewController: UITableViewController {
    // MARK: Variables
    var dataController: DataController!
    let brackets = ["2020 Joe Lunardi's Bracketology": "bracketology2020"]
    
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
        let bracket = Array(brackets.keys)[(indexPath as NSIndexPath).section]
        
        // Set the cell details
        cell.textLabel?.text = bracket
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Create the tournament, segue to the initial bracket
    }
}
