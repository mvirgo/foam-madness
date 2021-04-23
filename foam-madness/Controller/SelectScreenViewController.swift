//
//  SelectScreenViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/31/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit
import CoreData

class SelectScreenViewController: UIViewController {
    // MARK: IBOutlets
    @IBOutlet weak var resumeTournamentButton: UIButton!
    @IBOutlet weak var viewCompletedTournamentButton: UIButton!
    @IBOutlet weak var playGameButton: UIButton!
    @IBOutlet weak var singleGameLabel: UILabel!
    
    // MARK: Other variables
    var dataController: DataController!
    
    // MARK: View functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Make sure navbar appears
        navigationController?.setNavigationBarHidden(false, animated: true)
        // Show below based on logic of existing tournaments
        resumeTournamentButton.isHidden = checkCurrentTournaments()
        viewCompletedTournamentButton.isHidden = checkCompletedTournaments()
        // Make sure tournament buttons fit
        resumeTournamentButton.titleLabel?.adjustsFontSizeToFitWidth = true
        viewCompletedTournamentButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    // MARK: Other functions
    func checkCurrentTournaments() -> Bool {
        let predicate = NSPredicate(format: "completion == NO")
        return TourneyHelper.fetchData(dataController, predicate, "Tournament").count == 0
    }
    
    func checkCompletedTournaments() -> Bool {
        let predicate = NSPredicate(format: "completion == YES")
        return TourneyHelper.fetchData(dataController, predicate, "Tournament").count == 0
    }
    
    // MARK: IBActions
    @IBAction func resumeTournamentButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "chooseExistingTournament", sender: sender)
    }
    
    @IBAction func newTournamentButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "selectBracket", sender: sender)
    }
    
    @IBAction func simulateTournamentButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "selectSimulation", sender: sender)
    }
    
    @IBAction func viewCompletedTournamentButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "chooseCompletedTournament", sender: sender)
    }
    
    @IBAction func playGameButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "pickTeams", sender: sender)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Send data controller to next view controller
        // Thanks https://stackoverflow.com/questions/31457300/swift-prepareforsegue-with-two-different-segues
        if let identifier = segue.identifier {
            switch identifier {
            case "pickTeams":
                let vc = segue.destination as! SelectTeamsViewController
                vc.dataController = dataController
            case "selectBracket":
                let vc = segue.destination as! SelectInitialBracketViewController
                vc.dataController = dataController
                vc.isSimulated = false
            case "selectSimulation":
                let vc = segue.destination as! SelectInitialBracketViewController
                vc.dataController = dataController
                vc.isSimulated = true
            case "chooseExistingTournament":
                let vc = segue.destination as! SelectTournamentViewController
                vc.dataController = dataController
                vc.completedTournaments = false
            case "chooseCompletedTournament":
                let vc = segue.destination as! SelectTournamentViewController
                vc.dataController = dataController
                vc.completedTournaments = true
            case "viewLiveScores":
                print("Viewing live scores.")
            default:
                print("Unsupported segue.")
            }
        }
    }
}
