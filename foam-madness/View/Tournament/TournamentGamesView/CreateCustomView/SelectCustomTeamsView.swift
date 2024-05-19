//
//  SelectCustomTeamsView.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/18/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct SelectCustomTeamsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var game: Game
    @State var tournament: Tournament
    
    @State private var teams: [String] = []
    @State private var reverseTeamDict: [String: [String: String]] = [:]
    
    @State private var originalSeed1: Int16 = 1
    @State private var originalSeed2: Int16 = 1
    @State private var selectedSeed1: Int16 = 1
    @State private var selectedSeed2: Int16 = 1
    
    @State private var originalTeam1: String = ""
    @State private var originalTeam2: String = ""
    @State private var selectedTeam1: String = ""
    @State private var selectedTeam2: String = ""
    
    @State private var team1Searching = false
    @State private var team2Searching = false
    @State private var isValidating = false
    
    var body: some View {
        VStack(spacing: 5) {
            Spacer()
            
            if !(team1Searching || team2Searching) {
                Text("Update Teams & Seeds")
                    .foregroundColor(commonBlue)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            if !team2Searching {
                SearchTeamView(
                    isTyping: $team1Searching,
                    teamName: $selectedTeam1,
                    showParentButton: .constant(true),
                    label: "Team 1",
                    teams: teams
                )
                if !team1Searching {
                    SeedSelector(teamNum: 1, selectedSeed: $selectedSeed1)
                }
            }
            
            if !team1Searching {
                SearchTeamView(
                    isTyping: $team2Searching,
                    teamName: $selectedTeam2,
                    showParentButton: .constant(true),
                    label: "Team 2",
                    teams: teams
                )
                if !team2Searching {
                    SeedSelector(teamNum: 2, selectedSeed: $selectedSeed2)
                }
            }
            
            if !(team2Searching || team1Searching) {
                Spacer()
                if originalSeed1 != selectedSeed1 || originalSeed2 != selectedSeed2 {
                    Text("Changing seeds changes the probabilities used, but won't change game position in the bracket.")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding([.leading, .trailing])
                }
                
                Button("Confirm Changes") {
                    handleConfirmChanges()
                }
                .disabled(isValidating)
                .buttonStyle(PrimaryButtonFullWidthStyle())
                .scaleEffect(0.75)
                .padding([.leading, .trailing])
                
            }
        }
        .onAppear {
            setupView()
        }
    }
    
    private func setupView() {
        let loadedTeams = TeamHelper.loadTeams()
        let teamsNamesByIdDict = loadedTeams.teamsNamesByIdDict
        teams = loadedTeams.teams
        reverseTeamDict = loadedTeams.reverseTeamDict
        
        originalSeed1 = game.team1Seed
        originalSeed2 = game.team2Seed
        selectedSeed1 = game.team1Seed
        selectedSeed2 = game.team2Seed
        
        var team1 = ""
        var team2 = ""
        // Use teamsNamesByIdDict to avoid bug caused by lengthening names in v1.9
        if game.teams?.count == 2 {
            let orderedTeams = GameHelper.getOrderedTeams(game)
            team1 = teamsNamesByIdDict[String(orderedTeams[0].id)] ?? ""
            team2 = teamsNamesByIdDict[String(orderedTeams[1].id)] ?? ""
        } else if game.teams?.count == 1 {
            let team = game.teams?.allObjects.first as! Team
            let teamName = teamsNamesByIdDict[String(team.id)]
            if team.id == game.team1Id {
                team1 = teamName ?? ""
            } else {
                team2 = teamName ?? ""
            }
        }
        
        originalTeam1 = team1
        originalTeam2 = team2
        selectedTeam1 = team1
        selectedTeam2 = team2
    }
    
    private func handleConfirmChanges() {
        isValidating = true
        let isValidated = validateChange()
        isValidating = false
        if isValidated {
            updateTeamsAndSeeds()
        }
    }
    
    private func validateChange() -> Bool {
        if selectedTeam1 == "" && selectedTeam2 == "" {
            return true
        }
        
        if selectedTeam1 == selectedTeam2 {
            alertUser(title: "Invalid Teams", message: "Selected teams must be different.")
            return false
        }
        
        if selectedTeam1 != "" && originalTeam1 != selectedTeam1 {
            let teamId = Int16(reverseTeamDict[selectedTeam1]?["id"] ?? "-1") ?? -1
            let validation = TourneyHelper.checkForDuplicateTeamInTournament(
                tournament,
                currentGameId: game.tourneyGameId,
                teamId: teamId
            )
            if validation != nil {
                alertUser(
                    title: "Team Already Chosen",
                    message: TourneyHelper.duplicateTeamAlertMessage(
                        selectedTeam1,
                        validation
                    )
                )
                return false
            }
        }
        
        if selectedTeam2 != "" && originalTeam2 != selectedTeam2 {
            let teamId = Int16(reverseTeamDict[selectedTeam2]?["id"] ?? "-1") ?? -1
            let validation = TourneyHelper.checkForDuplicateTeamInTournament(
                tournament,
                currentGameId: game.tourneyGameId,
                teamId: teamId
            )
            if validation != nil {
                alertUser(
                    title: "Team Already Chosen",
                    message: TourneyHelper.duplicateTeamAlertMessage(
                        selectedTeam2,
                        validation
                    )
                )
                return false
            }
        }
        
        return true
    }
    
    private func updateTeamsAndSeeds() {
        game.team1Seed = selectedSeed1
        game.team2Seed = selectedSeed2
        GameHelper.updateTeamsInGame(selectedTeam1, selectedTeam2, game, reverseTeamDict, viewContext)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func alertUser(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertVC, animated: true, completion: nil)
    }
}

struct SelectCustomTeamsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let predicate = NSPredicate(format: "ready == NO")
        let tournaments = TourneyHelper.fetchDataFromContext(viewContext, predicate, "Tournament", []) as! [Tournament]
        let tournament = tournaments[0]
        let games = tournament.games?.allObjects as! [Game]
        let game = games.filter({ $0.tourneyGameId == 5}).first!
        return NavigationView {
            SelectCustomTeamsView(
                game: game,
                tournament: tournament
            ).environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
