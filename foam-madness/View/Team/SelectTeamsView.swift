//
//  SelectTeamsView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct SelectTeamsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    let loadedTeams = TeamHelper.loadTeams()
    @State private var teams: [String] = []
    @State private var reverseTeamDict: [String: [String: String]] = [:]

    @State private var team1: String = ""
    @State private var team2: String = ""
    @State private var showButton1 = false
    @State private var showButton2 = false
    @State private var shotsPerRound = AppConstants.defaultShotsPerRound
    
    @State private var progressToGame = false
    @State private var createdGame: Game?
    
    @State private var hideTeam1Search = false
    @State private var hideTeam2Search = false

    var body: some View {
        VStack {
            Text("Select Teams").foregroundColor(commonBlue).font(.largeTitle).fontWeight(.bold)
            
            VStack() {
                if !hideTeam1Search {
                    SearchTeamView(
                        isTyping: $hideTeam2Search,
                        teamName: $team1,
                        showParentButton: $showButton1,
                        label: "Team 1",
                        teams: teams
                    )
                }
                if !hideTeam2Search {
                    SearchTeamView(
                        isTyping: $hideTeam1Search,
                        teamName: $team2,
                        showParentButton: $showButton2,
                        label: "Team 2",
                        teams: teams
                    )
                }
                
                if (showButton1 && showButton2) {
                    Stepper("Shots per round: \(shotsPerRound)", value: $shotsPerRound, in: 3...15)
                        .padding([.leading, .trailing])
                    if (progressToGame) {
                        NavigationLink("", destination: PlayGameView(game: createdGame!), isActive: $progressToGame)
                    } else {
                        Button("Continue") {
                            createGame()
                        }
                        .buttonStyle(PrimaryButtonFullWidthStyle())
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            teams = loadedTeams.teams
            reverseTeamDict = loadedTeams.reverseTeamDict
        }
    }
    
    private func createGame() -> Void {
        if team1.isEmpty || team2.isEmpty {
            alertUser(title: "Please Select Teams", message: "Both teams need to be selected.")
            return
        }
        if $team1.wrappedValue == $team2.wrappedValue {
            alertUser(title: "Invalid Teams", message: "Selected teams must be different.")
            return
        }
        createdGame = GameHelper.prepareSingleGame(team1, team2, shotsPerRound, reverseTeamDict, viewContext)
        progressToGame = true
    }
    
    private func alertUser(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertVC, animated: true, completion: nil)
    }
}

struct SelectTeamsView_Previews: PreviewProvider {
    static var viewContext = PreviewDataController.shared.container.viewContext

    static var previews: some View {
        return NavigationView {
            SelectTeamsView().environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
