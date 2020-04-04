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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show below based on logic of existing tournaments
        resumeTournamentButton.isHidden = checkCurrentTournaments()
        viewCompletedTournamentButton.isHidden = checkCompletedTournaments()
    }
    
    // MARK: Other functions
    func fetchTournaments(_ predicate: NSPredicate) -> [Any] {
        // Get view context
        let context = dataController.viewContext
        // Get tournaments from Core Data
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tournament")
        fetchRequest.predicate = predicate
        // Fetch the results
        let results = try! context.fetch(fetchRequest)
        
        return results
    }
    
    func checkCurrentTournaments() -> Bool {
        let predicate = NSPredicate(format: "completion == NO")
        return fetchTournaments(predicate).count == 0
    }
    
    func checkCompletedTournaments() -> Bool {
        let predicate = NSPredicate(format: "completion == YES")
        return fetchTournaments(predicate).count == 0
    }
    
    // MARK: IBActions
    @IBAction func resumeTournamentButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "chooseExistingTournament", sender: sender)
    }
    
    @IBAction func newTournamentButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "selectBracket", sender: sender)
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
            case "chooseExistingTournament":
                let vc = segue.destination as! SelectTournamentViewController
                vc.dataController = dataController
                vc.completedTournaments = false
            case "chooseCompletedTournament":
                let vc = segue.destination as! SelectTournamentViewController
                vc.dataController = dataController
                vc.completedTournaments = true
            default:
                print("Unsupported segue.")
            }
        }
    }
}
