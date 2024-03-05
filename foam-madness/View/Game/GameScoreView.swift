//
//  GameScoreView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct GameScoreView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var team1: String?
    @State var team2: String?
    @State var team1Score = 0
    @State var team2Score = 0
    @State var game: Game
    @State var isTournament = true

    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Text("Final Score").font(.title).fontWeight(.bold)
                HStack {
                    Text(team1 ?? "").font(.largeTitle)            .minimumScaleFactor(0.5)
                    Spacer()
                    Text("\(team1Score)").font(.largeTitle)
                }
                HStack {
                    Text(team2 ?? "").font(.largeTitle)            .minimumScaleFactor(0.5)
                    Spacer()
                    Text("\(team2Score)").font(.largeTitle)
                }
            }.padding([.leading, .trailing])
            
            NavigationLink(destination: GameStatsView(game: game)) {
                Text("See Stats")
            }.buttonStyle(PrimaryButtonFullWidthStyle()).padding()
            
            if isTournament {
                Button("Back to Games", action: {
                    NavigationUtil.popToTournamentGames(tournamentName: game.tournament?.name ?? "")
                })
                .buttonStyle(PrimaryButtonFullWidthStyle()).padding()
            } else {
                Button("Back to Menu", action: {
                    NavigationUtil.popToRootView()
                })
                .buttonStyle(PrimaryButtonFullWidthStyle()).padding()
            }
        }
    }
}

struct GameScoreView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let games =
        TourneyHelper.fetchDataFromContext(viewContext, nil, "Game", []) as! [Game]
        let game = games[0]

        return NavigationView {
            GameScoreView(team1: "Kansas", team2: "Duke", team1Score: 80, team2Score: 76, game: game).environment(\.managedObjectContext, PreviewDataController.shared.container.viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
