//
//  TournamentGamesView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct TournamentGamesView: View {
    @State private var initialRound: Int16 = 0
    @State private var finalRound: Int16 = 6
    @State private var roundStepper: Int16 = 0
    @State private var roundText = "ROUND"
    @State private var games: [Game] = []
    @State var tournament: Tournament
    
    var body: some View {
        VStack {
            Text(GameHelper.getRoundString(roundStepper))
                .foregroundColor(commonBlue)
                .font(.largeTitle)
                .fontWeight(.bold)

            List {
                ForEach(games.filter({ $0.round == roundStepper }), id: \.id) { game in
                    TournamentGameCell(game: game)
                }
            }
            Text("Change Round")
                .foregroundColor(commonBlue)
                .font(.title2)
                .fontWeight(.bold)
            Stepper(value: $roundStepper, in: initialRound...finalRound) {
                Text("")
            }
                .labelsHidden()
                .padding([.bottom])
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationTitle(tournament.name ?? "Tournament Games")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Main Menu", action: {
                    NavigationUtil.popToRootView()
                })
            }
            ToolbarItem(placement: .topBarTrailing) {
                if !tournament.isSimulated {
                    NavigationLink("Stats", destination: TournamentStatsView(tournament: tournament))
                }
            }
        }
        .onAppear {
            getSortedGames()
        }
        .tag("TournamentGames")
    }
    
    func getSortedGames() {
        let gamesArray = Array(tournament.games!) as! [Game]
        games = gamesArray.sorted() { $0.tourneyGameId < $1.tourneyGameId }
        
        let minRound = games.min(by: { $0.round < $1.round })?.round ?? 0
        finalRound = games.max(by: { $0.round < $1.round })?.round ?? 6
        initialRound = minRound
        roundStepper = minRound
    }
}

struct TournamentGamesView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let tournaments = TourneyHelper.fetchDataFromContext(viewContext, nil, "Tournament", []) as! [Tournament]
        return NavigationView {
            TournamentGamesView(tournament: tournaments[0]).environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
