//
//  ListCustomTeamsView.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct ListCustomTeamsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @State var tournament: Tournament
    @Binding var isReady: Bool
    @State private var games: [Game] = []
    @State private var showHelper = false
    @State private var showReadyGames = false
    @State private var readyTotal = 0
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(showReadyGames ? "Ready Games" : "Select Teams")
                    .font(.title)
                    .fontWeight(.bold)
                Button(action: { showHelper = !showHelper }) {
                    Image(systemName: "info.circle")
                }.font(.title2)
            }
            .foregroundColor(commonBlue)
            
            if showHelper {
                Text(showReadyGames
                    ? "These games have both teams selected, but you can still change them."
                    : "These games need one or both teams selected still."
                )
                .font(.callout)
                .foregroundColor(.secondary)
            }
            
            List {
                ForEach(games.filter({
                    showReadyGames
                    ? $0.teams?.count == 2
                    : $0.teams?.count != 2
                }), id: \.id) { game in
                    TournamentListGameCell(game: game, allowSelection: true)
                        .listRowBackground(showReadyGames ? Color.green.opacity(0.2) : Color.gray)
                }
            }.listStyle(.plain)
            
            Picker("", selection: $showReadyGames) {
                Text("Need Teams").tag(false)
                Text("Ready").tag(true)
            }
            .pickerStyle(.segmented)
            
            Text("\(readyTotal) / \(games.count) games ready")
                .font(.headline)
            
            if games.count > 2 {
                // Final Four can't change
                NavigationLink("Change Region Names", destination: UpdateRegionsView(games: tournament.games!))
            }
            
            if readyTotal == games.count {
                Button("\(tournament.isSimulated ? "Sim" : "Create") Tournament") {
                    handleContinue()
                }
                .buttonStyle(PrimaryButtonFullWidthStyle())
                .scaleEffect(0.8)
            }
        }
        .padding()
        .onAppear {
            getSortedInitialRoundGames()
        }
    }
    
    private func getSortedInitialRoundGames() {
        let gamesArray = Array(tournament.games!) as! [Game]
        let minRound = gamesArray.min(by: { $0.round < $1.round })?.round ?? 0
        let initialRoundGames = gamesArray.filter({ $0.round == minRound })
        games = initialRoundGames.sorted() { $0.tourneyGameId < $1.tourneyGameId }
        
        // Default to ready tab if no games need selection
        let gamesWithoutBothTeams = games.filter({ $0.teams?.count ?? 0 < 2})
        if gamesWithoutBothTeams.count == 0 {
            showReadyGames = true
        }
        
        readyTotal = games.count - gamesWithoutBothTeams.count
    }
    
    private func handleContinue() {
        alertUser(
            title: "Locked In",
            message: "Once you continue, you can no longer make changes to the bracket, and your tournament will be \(tournament.isSimulated ? "simulated" : "created").",
            isContinueCheck: true
        )
    }
    
    private func createTournament() {
        BracketCreationController(context: viewContext).finalizeCustomBracket(tournament)
        if tournament.isSimulated {
            let winner = BracketCreationController(context: viewContext)
                .simulateTournament(tournament: tournament)
            // Notify user of winner
            let title = "Tournament Complete"
            let message = "\(winner) wins the tournament! (Sim)"
            alertUser(title: title, message: message, isContinueCheck: false)
        }
        isReady = true
    }
    
    private func alertUser(title: String, message: String, isContinueCheck: Bool) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            if isContinueCheck {
                createTournament()
            }
        }))
        
        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertVC, animated: true, completion: nil)
    }
}

struct ListCustomTeamsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let predicate = NSPredicate(format: "ready == NO")
        let tournaments = TourneyHelper.fetchDataFromContext(viewContext, predicate, "Tournament", []) as! [Tournament]
        return NavigationView {
            ListCustomTeamsView(
                tournament: tournaments[0],
                isReady: .constant(false)
            ).environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
