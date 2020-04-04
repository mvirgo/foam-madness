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
        // TODO: Sections for regions and/or completed games?
        // Get the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "tourneyGameCell", for: indexPath)
        // Get the correct game for the cell
        let game = games[(indexPath as NSIndexPath).row]
        
        // TODO: Add the score if the game was already played
        // Set the cell details if game is ready to play
        if game.teams?.count == 2 {
            let teams = GameHelper.getOrderedTeams(game)
            let team1 = teams[0]
            let team2 = teams[1]
            cell.textLabel?.text = "\(game.team1Seed) \(team1.name!) vs. \(game.team2Seed) \(team2.name!)"
        } else {
            cell.textLabel?.text = "Game Pending Both Participants"
        }
        cell.detailTextLabel?.text = game.region!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedGame = games[(indexPath as NSIndexPath).row]
        // Do segues or not based on if game is completed or ready to play
        if selectedGame.completion {
            // Segue to game stats instead of game play
            performSegue(withIdentifier: "showCompletedTourneyGame", sender: nil)
        } else if selectedGame.teams?.count == 2 {
            // Game is ready to play, segue to play game view
            performSegue(withIdentifier: "playTourneyGame", sender: nil)
        }
    }
    
    // MARK: IBActions
    @IBAction func roundStepperPressed(_ sender: Any) {
        // Update the round view
        getGamesForRound()
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Send data controller to Play Game View Controller
        if let vc = segue.destination as? PlayGameViewController {
            vc.dataController = dataController
            vc.game = selectedGame
        }
        // Or send data to Game Score View Controller
        if let vc = segue.destination as? GameScoreViewController {
            vc.dataController = dataController
            vc.game = selectedGame
        }
    }
}
