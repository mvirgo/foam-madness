//
//  SelectTournamentViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 4/3/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit
import CoreData

class SelectTournamentViewController: UITableViewController {
    // MARK: Variables
    var dataController: DataController!
    var completedTournaments: Bool!
    var tournamentsFetched: [Tournament]!
    var selectedTournament: Tournament!
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add a page title
        if completedTournaments {
            navigationItem.title = "Choose a Completed Tournament"
        } else {
            navigationItem.title = "Choose an Existing Tournament"
        }
        // Load in the desired tournaments
        let results: [Any]
        if completedTournaments {
            let predicate = NSPredicate(format: "completion == YES")
            results = TourneyHelper.fetchTournaments(dataController, predicate)
        } else {
            let predicate = NSPredicate(format: "completion == NO")
            results = TourneyHelper.fetchTournaments(dataController, predicate)
        }
        tournamentsFetched = (results as! [Tournament])
    }
    
    // MARK: Table View functionality
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tournamentsFetched.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tournamentCell", for: indexPath)
        let tournament = tournamentsFetched[(indexPath as NSIndexPath).row]
        
        // Set the cell details
        cell.textLabel?.text = tournament.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTournament = tournamentsFetched[(indexPath as NSIndexPath).row]
        // Segue to tournament games view
        performSegue(withIdentifier: "showExistingTourneyGames", sender: nil)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Send data controller & tourney to Tournament Games Controller
        if let vc = segue.destination as? TournamentGamesViewController {
            vc.dataController = dataController
            vc.tournament = selectedTournament
        }
    }
}
