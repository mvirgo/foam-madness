//
//  BracketCreationView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct BracketCreationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    // Passed from previous
    @State var isCustom: Bool
    @State var isSimulated: Bool
    @State var isWomens: Bool
    @State var numTeams: Int // ignored if non-custom
    @State var chosenBracketFile: String
    
    @State private var showProgress = false
    @State private var progress = 0.0
    @State private var shotsPerRound = AppConstants.defaultShotsPerRound
    @State private var tournamentName = ""
    @State private var rightHanded = true
    @State private var showShotsHelper = false
    @State private var tournamentReady = false
    @State private var tournament: Tournament!

    var body: some View {
        VStack(spacing: 20) {
            if (showProgress) {
                ProgressView()
            }
            
            Text("Enter Tournament Name").font(.title)
            TextField("Tournament Name", text: $tournamentName)
                .font(.title2)
                .border(Color(UIColor.secondarySystemBackground))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            if (!isSimulated) {
                Toggle("\(rightHanded ? "Right" : "Left")-Hand Dominant", isOn: $rightHanded)
                    .toggleStyle(SwitchToggleStyle(tint: commonBlue))
                    .font(.title2)
                HStack {
                    Text("Shots per round: \(shotsPerRound)")
                    Button(action: onClickShotsHelper) {
                        Image(systemName: "info.circle")
                            .foregroundColor(commonBlue)
                    }
                    Spacer()
                    Stepper("", value: $shotsPerRound, in: 3...15)
                        .labelsHidden()
                }.font(.title2)
                if showShotsHelper {
                    Text("Shots per round controls how many 1 point, 2 point, etc., shot attempts per team each game.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
            }
            
            if (tournamentReady) {
                NavigationLink("", destination: TournamentGamesView(
                    showBracketView: tournament.useBracketView,
                    tournament: tournament
                ), isActive: $tournamentReady)
            } else {
                let buttonText = isCustom
                    ? "Continue"
                    : "\(isSimulated ? "Sim" : "Create") Tournament"
                Button(buttonText, action: { createTournament() })
                    .buttonStyle(PrimaryButtonFullWidthStyle())
            }
            
            if (showProgress) {
                ProgressView(value: progress).padding(50)
            }
        }
        .padding()
    }
    
    private func createTournament() {
        if !isValidName() {
            return
        }
        if (isCustom) {
            tournament = BracketCreationController(context: viewContext)
                .createCustomBracket(numTeams: numTeams, isWomens: isWomens, tournamentName: tournamentName, isSimulated: isSimulated, useLeft: !rightHanded, shotsPerRound: shotsPerRound)
        } else {
            tournament = BracketCreationController(context: viewContext)
                .createBracketFromFile(bracketLocation: chosenBracketFile, tournamentName: tournamentName, isSimulated: isSimulated, useLeft: !rightHanded, shotsPerRound: shotsPerRound)
        }
        if (isSimulated && !isCustom) {
            let winner = BracketCreationController(context: viewContext)
                .simulateTournament(tournament: tournament)
            // Notify user of winner
            let title = "Tournament Complete"
            let message = "\(winner) wins the tournament! (Sim)"
            alertUser(title: title, message: message, true)
        } else {
            tournamentReady = true
        }
    }
    
    private func isValidName() -> Bool {
        if tournamentName != "" {
            if isSimulated {
                tournamentName += " (Sim)"
            }
            if BracketCreationController(context: viewContext).checkExistingNames(tournamentName) {
                // New tourney name
                return true
            } else {
                // Tell user to find a new name
                alertUser(title: "Invalid Name", message: "Tournament name already taken.", false)
                return false
            }
        } else {
            // Tell user to input a name
            alertUser(title: "Invalid Name", message: "Tournament name cannot be blank.", false)
            return false
        }
    }
    
    private func onClickShotsHelper() {
        showShotsHelper = !showShotsHelper
    }
    
    private func alertUser(title: String, message: String, _ endTournament: Bool) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if endTournament {
            // Segue to table view of all playable games when done
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                tournamentReady = true
            }))
        } else {
            // Come back to view after
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        
        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertVC, animated: true, completion: nil)
    }
}

struct BracketCreationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BracketCreationView(
                isCustom: false, isSimulated: false, isWomens: false, numTeams: 0, chosenBracketFile: "mensBracket2023"
            ).environment(\.managedObjectContext, PreviewDataController.shared.container.viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
