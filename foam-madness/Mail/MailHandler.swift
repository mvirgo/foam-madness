//
//  MailHandler.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/11/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import MessageUI

class MailHandler: NSObject, MFMailComposeViewControllerDelegate {
    func sendTournamentStatsEmail(tournamentName: String, exportGames: [String: [String: String]]) {
        // Export all games in the tournament to JSON
        // Thanks https://stackoverflow.com/questions/28325268/convert-array-to-json-string-in-swift
        do {
            let jsonExport = try JSONSerialization.data(withJSONObject: ["games": exportGames], options: JSONSerialization.WritingOptions.prettyPrinted)
            // Let user email it to themselves
            // From Apple documentation: https://developer.apple.com/documentation/messageui/mfmailcomposeviewcontroller
            if MFMailComposeViewController.canSendMail() {
                let viewController = UIApplication.shared.windows.first!.rootViewController!
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                
                // Configure the fields of the interface.
                composeVC.addAttachmentData(jsonExport, mimeType: "application/json", fileName: "\(tournamentName)-export.json")
                composeVC.setSubject("My Foam Madness Export")
                composeVC.setMessageBody("Attached is my tournament data in JSON!", isHTML: false)
                
                // Present the view controller modally.
                viewController.present(composeVC, animated: true, completion: nil)
            } else {
                alertUser(title: "Mail Unavailable",
                          message: "Mail services are not available; cannot export.")
            }
        } catch {
            alertUser(title: "Export Issue", message: "Data export failed.")
        }
    }
    
    private func alertUser(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertVC, animated: true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
