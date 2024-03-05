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
    @State var tournament: Tournament
    // TODO: Remove
    @State var game: Game?
    
    var body: some View {
        VStack {
            RoundLabelView(round: $round)
            // TODO: Add color based on game status
            // TODO: Add in games list
            //        List {
            //            ForEach([], id: \.self) { game in
            //                Text("Game")
            //            }
            //        }
            NavigationLink("Play", destination: PlayGameView(game: game!))
            Text("Change Round")
                .foregroundColor(commonBlue)
                .font(.title2)
                .fontWeight(.bold)
            Stepper(value: $round, in: 0...6) {
                Text("")
            }
                .labelsHidden()
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
        let games =
        TourneyHelper.fetchDataFromContext(viewContext, nil, "Game", []) as! [Game]
        let game = games[0]
        return NavigationView {
            TournamentGamesView(tournament: tournaments[0], game: game).environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
