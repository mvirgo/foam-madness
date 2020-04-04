//
//  TournamentGamesViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 4/3/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit
import CoreData

// Thanks https://stackoverflow.com/questions/31673607/swift-tableview-in-viewcontroller/31691216
class TournamentGamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: IBOutlets
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var gameTableView: UITableView!
    @IBOutlet weak var roundStepper: UIStepper!
    
    // MARK: Other variables
    var dataController: DataController!
    var tournament: Tournament!
    var games = [Game]()
    var selectedGame: Game!
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add a page title
        navigationItem.title = "\(tournament.name!) Games"
        // Set delegate and datasource for the game table view
        self.gameTableView.delegate = self
        self.gameTableView.dataSource = self
        // Get data on the games
        getGamesForRound()
    }
    
    // MARK: Other functions
    func getGamesForRound() {
        // Make sure games is now empty
        games.removeAll(keepingCapacity: true)
        // Get current round to view
        let round = Int16(roundStepper.value)
        // Get all games with that round in the tournaments
        for game in Array(tournament!.games!) as! [Game] {
            if game.round == round {
                games.append(game)
            }
        }
        // Reload the table view
        gameTableView.reloadData()
        // Set the top label name
        if round <= 4 {
            roundLabel.text = GameHelper.getRoundString(round)
        } else if round == 5 {
            roundLabel.text = "Final Four"
        } else {
            roundLabel.text = "Championship"
        }
    }
    
    // MARK: Table View functionality
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Hold two teams for use later
        let team1: Team
        let team2: Team
        // Get the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "tourneyGameCell", for: indexPath)
        // Get the correct game for the cell
        let game = games[(indexPath as NSIndexPath).row]
        
        // Set the cell details if game is ready to play
        if game.teams?.count == 2 {
            let checkTeam = game.teams?.allObjects[0] as! Team
            if checkTeam.id == game.team1Id {
                team1 = checkTeam
                team2 = game.teams?.allObjects[1] as! Team
            } else {
                team1 = game.teams?.allObjects[1] as! Team
                team2 = checkTeam
            }
            cell.textLabel?.text = "\(game.team1Seed) \(team1.name!) vs. \(game.team2Seed) \(team2.name!)"
            cell.detailTextLabel?.text = game.region! + " Region"
        } else {
            cell.textLabel?.text = "Game Pending Both Participants"
            cell.detailTextLabel?.text = game.region! + " Region"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedGame = games[(indexPath as NSIndexPath).row]
        // TODO: Segue to play game view
    }
    
    @IBAction func roundStepperPressed(_ sender: Any) {
        // Update the round view
        getGamesForRound()
    }
}
