//
//  TournamentGamesView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct TournamentGamesView: View {
    @State private var round: Int16 = 0
    @State private var roundText = "ROUND"
    @State private var games: [Game] = []
    @State var tournament: Tournament
    
    var body: some View {
        VStack {
            RoundLabelView(round: $round)
            // TODO: Add color based on game status
            // TODO: Add in games list logic
            List {
                ForEach(games.filter({ $0.round == round }), id: \.self) { game in
                    if game.teams?.count == 2 {
                        let teams = GameHelper.getOrderedTeams(game)
                        let team1 = teams[0]
                        let team2 = teams[1]
                        let text = "\(team1.name) vs \(team2.name)"
                        if game.completion == false {
                            NavigationLink(text, destination: PlayGameView(game: game))
                        } else {
                            NavigationLink(text, destination: GameScoreView(game: game))
                        }
                    } else {
                        Text("Pending participants")
                    }
                }
            }
            Text("Change Round")
                .foregroundColor(commonBlue)
                .font(.title2)
                .fontWeight(.bold)
            Stepper(value: $round, in: 0...6) {
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
                NavigationLink("Stats", destination: TournamentStatsView())
            }
        }
        .onAppear {
            // TODO: Improve this logic
            games = Array(tournament.games!) as! [Game]
        }
        .tag("TournamentGames")
    }
}

struct RoundLabelView: View {
    @Binding var round: Int16

    var body: some View {
        Text(GameHelper.getRoundString(round))
            .foregroundColor(commonBlue)
            .font(.largeTitle)
            .fontWeight(.bold)
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
