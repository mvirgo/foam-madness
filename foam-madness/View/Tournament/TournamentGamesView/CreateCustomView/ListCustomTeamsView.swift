//
//  ListCustomTeamsView.swift
//  foam-madness
//
//  Created by Michael Virgo on 5/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct ListCustomTeamsView: View {
    @State var tournament: Tournament
    @State private var games: [Game] = []
    @State private var showHelper = false
    @State private var showReadyGames = false
    @State private var readyTotal = 0
    
    var body: some View {
        // TODO: Logic to verify when can continue
        // TODO: Logic to update to ready & save; check this changes view
        VStack(spacing: 10) {
            HStack {
                Text(showReadyGames ? "Ready Games" : "Select Teams")
                    .font(.largeTitle)
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
                }
            }.listStyle(.plain)
            
            Picker("", selection: $showReadyGames) {
                Text("Need Teams").tag(false)
                Text("Ready").tag(true)
            }
            .pickerStyle(.segmented)
            
            Text("\(readyTotal) / \(games.count) games ready")
                .font(.headline)
            
            Button("Continue") {
                // TODO: Add continue logic
            }.buttonStyle(PrimaryButtonFullWidthStyle())
        }
        .padding()
        .onAppear {
            getSortedInitialRoundGames()
        }
    }
    
    func getSortedInitialRoundGames() {
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
    
    // TODO: Func to validate + ready tournament; may need to dismiss view?
    // TODO: Alert when continuing that will create or sim
}

struct ListCustomTeamsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let predicate = NSPredicate(format: "ready == NO")
        let tournaments = TourneyHelper.fetchDataFromContext(viewContext, predicate, "Tournament", []) as! [Tournament]
        return NavigationView {
            ListCustomTeamsView(tournament: tournaments[0]).environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
