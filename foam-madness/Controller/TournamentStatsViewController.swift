//
//  TournamentStatsViewController.swift
//  foam-madness
//
//  Created by Michael Virgo on 4/10/20.
//  Copyright © 2020 mvirgo. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class TournamentStatsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    // MARK: IBOutlets
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var gamesVsOppLabel: UILabel!
    @IBOutlet weak var upsetsVsOppLabel: UILabel!
    @IBOutlet weak var winPercentageLabel: UILabel!
    @IBOutlet weak var gamesVsSameLabel: UILabel!
    @IBOutlet weak var overtimeFGLabel: UILabel!
    @IBOutlet var allStats : [UILabel]!
    @IBOutlet weak var statControl: UISegmentedControl!
    
    // MARK: Variables
    var dataController: DataController!
    var tournamentStatsController: TournamentStatsController!
    var tournament: Tournament!
    var games = [Game]()
    // Create arrays to hold stats information
    var totalStatsArray = [Int](repeating: 0, count: 11)
    var leftStatsArray = [Int](repeating: 0, count: 11)
    var rightStatsArray = [Int](repeating: 0, count: 11)
    var hasOvertimeStats = false
    
    // MARK: View functions
    override func viewDidLoad() {
        tournamentStatsController = TournamentStatsController(context: dataController.viewContext)
        // Get tourney games completed so far
        games = tournamentStatsController.getCompletedGames(tournament)
        // Calculate stats by total, left and right hands
        if games.count > 0 { // Leave stats at zero if nothing played yet
            let stats = tournamentStatsController.calculateAllStats(games)
            totalStatsArray = stats.totalStatsArray
            leftStatsArray = stats.leftStatsArray
            rightStatsArray = stats.rightStatsArray
            hasOvertimeStats = stats.hasOvertimeStats
        }
        // Display the calculated stats
        setDisplay()
        // Add right export button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(self.exportButtonPressed))
    }
    
    // MARK: Other functions
    func setDisplay() {
        // Set labels using correct stats for selected segment
        if statControl.selectedSegmentIndex == 0 { // Total
            headerLabel.text = "Total Stats"
            gamesVsOppLabel.text = "Games"
            upsetsVsOppLabel.text = "Upsets"
            winPercentageLabel.isHidden = true // not applicable
            allStats[2].isHidden = true
            gamesVsSameLabel.isHidden = true // not applicable
            allStats[3].isHidden = true
            // Set all stats labels
            for i in 0...allStats!.count-1 {
                allStats[i].text = String(totalStatsArray[i])
            }
        } else if statControl.selectedSegmentIndex == 1 { // Left
            headerLabel.text = "Left Hand Stats"
            gamesVsOppLabel.text = "Games vs R"
            upsetsVsOppLabel.text = "Upsets vs R"
            winPercentageLabel.isHidden = false
            allStats[2].isHidden = false
            winPercentageLabel.text = "Win % vs R"
            gamesVsSameLabel.isHidden = false
            allStats[3].isHidden = false
            gamesVsSameLabel.text = "Games vs L"
            // Set all stats labels
            for i in 0...allStats!.count-1 {
                allStats[i].text = String(leftStatsArray[i])
            }
        } else { // Right
            headerLabel.text = "Right Hand Stats"
            gamesVsOppLabel.text = "Games vs L"
            upsetsVsOppLabel.text = "Upsets vs L"
            winPercentageLabel.isHidden = false
            allStats[2].isHidden = false
            winPercentageLabel.text = "Win % vs L"
            gamesVsSameLabel.isHidden = false
            allStats[3].isHidden = false
            gamesVsSameLabel.text = "Games vs R"
            // Set all stats labels
            for i in 0...allStats!.count-1 {
                allStats[i].text = String(rightStatsArray[i])
            }
        }
        // Hide overtime if not applicable
        if hasOvertimeStats {
            overtimeFGLabel.isHidden = false
            allStats[10].isHidden = false
        } else {
            overtimeFGLabel.isHidden = true
            allStats[10].isHidden = true
        }
    }
    
    func alertUser(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: IBActions
    @IBAction func statControlPressed(_ sender: Any) {
        setDisplay()
    }
    
    @objc func exportButtonPressed() {
        // Export all games in the tournament to JSON
        var exportGames = [String: [String: String]]()
        for game in tournament.games! {
            let singleGame = GameHelper.createGameExportData(game as! Game)
            let key = singleGame.keys.first!
            exportGames[key] = singleGame[key]
        }
        // Thanks https://stackoverflow.com/questions/28325268/convert-array-to-json-string-in-swift
        do {
            let jsonExport = try JSONSerialization.data(withJSONObject: ["games": exportGames], options: JSONSerialization.WritingOptions.prettyPrinted)
            // Let user email it to themselves
            // From Apple documentation: https://developer.apple.com/documentation/messageui/mfmailcomposeviewcontroller
            if MFMailComposeViewController.canSendMail() {
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                
                // Configure the fields of the interface.
                composeVC.addAttachmentData(jsonExport, mimeType: "application/json", fileName: "\(tournament.name!)-export.json")
                composeVC.setSubject("My Foam Madness Export")
                composeVC.setMessageBody("Attached is my tournament data in JSON!", isHTML: false)
                
                // Present the view controller modally.
                self.present(composeVC, animated: true, completion: nil)
            } else {
                alertUser(title: "Mail Unavailable",
                          message: "Mail services are not available; cannot export.")
            }
        } catch {
            alertUser(title: "Export Issue", message: "Data export failed.")
        }
    }
    
    // MARK: Mail delegate functions
    // From Apple documentation: https://developer.apple.com/documentation/messageui/mfmailcomposeviewcontroller
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}
