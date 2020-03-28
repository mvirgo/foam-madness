//
//  PlayGameViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/27/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit

class PlayGameViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var team1: UILabel!
    @IBOutlet weak var team2: UILabel!

    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setTeamNames()
    }
    
    // MARK: Other functions
    func setTeamNames() {
        // TODO: Get team names from a different view and replace below
        team1.text = "Kansas"
        team2.text = "Duke"
    }

    // MARK: IBActions
    @IBAction func playGamePressed(_ sender: Any) {
        performSegue(withIdentifier: "playGame", sender: nil)
    }
    
}

