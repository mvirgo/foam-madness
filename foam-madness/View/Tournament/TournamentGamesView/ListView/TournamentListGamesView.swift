//
//  TournamentListGamesView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct TournamentListGamesView: View {
    @State private var initialRound: Int16 = 0
    @State private var finalRound: Int16 = 6
    @State private var roundStepper: Int16 = 0
    @State private var roundText = "ROUND"
    @State private var games: [Game] = []
    @State var tournament: Tournament
    @Binding var bracketView: Bool
    
    var body: some View {
        VStack {
            Text(GameHelper.getRoundString(roundStepper))
                .foregroundColor(commonBlue)
                .font(.largeTitle)
                .fontWeight(.bold)

            List {
                ForEach(games.filter({ $0.round == roundStepper }), id: \.id) { game in
                    TournamentListGameCell(game: game)
                }
            }.listStyle(.plain)
            
            HStack {
                // Hide below to keep spacing
                BracketIcon()
                    .scaleEffect(CGSize(width: 0.15, height: 0.15))
                    .hidden()
                    .disabled(true)
                Spacer()
                VStack {
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
                Spacer()
                Button(action: { useBracketView() }) {
                    BracketIcon()
                        .scaleEffect(CGSize(width: 0.15, height: 0.15))
                }
            }.padding([.leading, .trailing])
        }
        .onAppear {
            getSortedGames()
        }
        .onDisappear {
            tournament.lastRoundViewed = roundStepper
        }
    }
    
    func getSortedGames() {
        let gamesArray = Array(tournament.games!) as! [Game]
        games = gamesArray.sorted() { $0.tourneyGameId < $1.tourneyGameId }
        
        let minRound = games.min(by: { $0.round < $1.round })?.round ?? 0
        finalRound = games.max(by: { $0.round < $1.round })?.round ?? 6
        initialRound = minRound
        
        let lastRoundViewed = tournament.lastRoundViewed
        if minRound > lastRoundViewed {
            roundStepper = minRound
            tournament.lastRoundViewed = minRound
        } else {
            roundStepper = lastRoundViewed
        }
    }
    
    func useBracketView() {
        bracketView = true
    }
}

struct TournamentListGamesView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let tournaments = TourneyHelper.fetchDataFromContext(viewContext, nil, "Tournament", []) as! [Tournament]
        return NavigationView {
            TournamentListGamesView(tournament: tournaments[0], bracketView: .constant(false)).environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
