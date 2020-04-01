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
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Show below based on logic of existing tournaments
        resumeTournamentButton.isHidden = true
        viewCompletedTournamentButton.isHidden = true
    }
    
    // MARK: IBActions
    @IBAction func resumeTournamentButtonPressed(_ sender: Any) {
    }
    
    @IBAction func newTournamentButtonPressed(_ sender: Any) {
    }
    
    @IBAction func viewCompletedTournamentButtonPressed(_ sender: Any) {
    }
    
    @IBAction func playGameButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "pickTeams", sender: sender)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: Update below as needed for different segues?
        // Send data controller to next view controller
        if let vc = segue.destination as? SelectTeamsViewController {
            vc.dataController = dataController
        }
    }
}
