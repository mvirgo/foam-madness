//
//  ShootModeViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/27/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit

class ShootModeViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var shotType: UILabel!
    @IBOutlet weak var handSide: UILabel!
    // Thanks https://stackoverflow.com/questions/50068413/array-of-uibuttons-in-swift-4
    @IBOutlet var boxes : [UIButton]!
    
    // MARK: Other variables
    var dataController: DataController!
    var game: Game!
    var team1: Team!
    var team2: Team!
    // TODO: Get the proper score multiplier for the shot type
    var scoreMultiplier = 3
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set ball images based on click state
        boxes.forEach {
            $0.setBackgroundImage(UIImage(named: "basketball-gray"), for: .normal)
            $0.setBackgroundImage(UIImage(named: "basketball"), for: .selected)
        }
        
        // TODO: Feed in information on team name, shot type and hand side
        teamName.text = "Kansas"
        shotType.text = "3-points"
        handSide.text = "Right"
    }
    
    // MARK: Other functions
    
    
    // MARK: IBActions
    @IBAction func ballButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func finishedButtonPressed(_ sender: Any) {
        // TODO: Change below to feed total count to stats and score
        var count = 0
        boxes.forEach {
            if $0.isSelected {
                count += 1
            }
        }
        print(count)
        print(count * scoreMultiplier)
        
        // TODO: Either continue game or finish to game score
        performSegue(withIdentifier: "finishGame", sender: nil)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: Add any other necessary processing before game score shown
        // Send data controller to GameScoreViewController if that's destination
        if let vc = segue.destination as? GameScoreViewController {
            vc.dataController = dataController
        }
    }

}
