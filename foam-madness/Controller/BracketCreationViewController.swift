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
    var isSimulated: Bool!
    var tournament: Tournament!
    var tournamentName: String!
    var hasFirstFour = false
    var bracketLocation: String!
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide unneeded progress indictators
        activityIndicator.hidesWhenStopped = true
        progressBar.isHidden = true
        // Set text field delegate so keyboard is handled appropriately
        self.tourneyNameTextField.delegate = self
        // Set button title & hand switch details
        setButtonAndHandSwitch()
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
    func setButtonAndHandSwitch() {
        // Set button title & hand switch based on whether it is a simulation
        if isSimulated {
            createTournamentButton.setTitle("Sim Tournament", for: .normal)
            dominantHandLabel.isHidden = true
            handSwitch.isHidden = true
        } else {
            createTournamentButton.setTitle("Create Tournament", for: .normal)
            dominantHandLabel.isHidden = false
            handSwitch.isHidden = false
        }
    }
    
    func alertUser(title: String, message: String, _ endTournament: Bool) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if endTournament {
            // Segue to table view of all playable games when done
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.segueToGamesTable()
            }))
        } else {
            // Come back to view after
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        self.present(alertVC, animated: true, completion: nil)
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
    
    func simulateTournament() {
        taskLabel.text = "Simulating tournament games..."
        
        let winner = BracketCreationController(context: dataController.viewContext)
            .simulateTournament(tournament: tournament, hasFirstFour: hasFirstFour)
        
        // Notify user of winner
        let title = "Tournament Complete"
        let message = "\(winner) wins the tournament! (Sim)"
        alertUser(title: title, message: message, true)
    }
    
    func segueToGamesTable() {
        performSegue(withIdentifier: "showNewTourneyGames", sender: nil)
    }
    
    // MARK: IBActions
    @IBAction func createTournamentButtonPressed(_ sender: Any) {
        // Set the tournament name based on user input
        let name = tourneyNameTextField.text
        if name != "" {
            if BracketCreationController(context: dataController.viewContext).checkExistingNames(name!) { // New tourney name
                tournamentName = tourneyNameTextField.text
                if isSimulated {
                    tournamentName += " (Sim)"
                }
            } else {
                // Tell user to find a new name
                alertUser(title: "Invalid Name", message: "Tournament name already taken.", false)
                return
            }
        } else {
            // Tell user to input a name
            alertUser(title: "Invalid Name", message: "Tournament name cannot be blank.", false)
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
        // Create the bracket
        taskLabel.text = "Creating bracket..."
        let bracketOutput = BracketCreationController(context: dataController.viewContext)
            .createBracket(
                bracketLocation: bracketLocation,
                tournamentName: tournamentName,
                isSimulated: isSimulated,
                useLeft: checkLeftHand()
            )
        tournament = bracketOutput.tournament
        hasFirstFour = bracketOutput.hasFirstFour
        // End activity indicator motion
        activityIndicator.stopAnimating()
        // Simulate, if applicable
        if isSimulated {
            simulateTournament()
        } else {
            // Segue to table view of all playable games
            segueToGamesTable()
        }
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
