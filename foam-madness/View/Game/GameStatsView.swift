//
//  GameStatsView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct GameStatsView: View {
    @State var team1: String?
    @State var team2: String?
    @State var team1Score = 0
    @State var team2Score = 0
    @State var game: Game
    @State var isTournament = false
    @State var directFromTournament = false

    var body: some View {
        VStack {
            HStack(spacing: 5) {
                VStack {
                    Text("X").font(.largeTitle).opacity(0)
                    Text("Hand")
                    Text("Total FG%")
                    Text("1 PT%")
                    Text("2 PT%")
                    Text("3 PT%")
                    Text("4 PT%")
                    // TODO: Conditionally show
                    Text("OT PTS")
                    Text("OT FG%")
                }.font(.title)
                Spacer()
                VStack {
                    // TODO: Replace all below w/ game vars
                    Text(team1 ?? "").font(.largeTitle)
                    Text("Hand")
                    Text("Total FG%")
                    Text("1 PT%")
                    Text("2 PT%")
                    Text("3 PT%")
                    Text("4 PT%")
                    // TODO: Conditionally show
                    Text("OT PTS")
                    Text("OT FG%")
                }.font(.title)
                Spacer()
                VStack {
                    // TODO: Replace all below w/ game vars
                    Text(team2 ?? "").font(.largeTitle)
                    Text("Hand")
                    Text("Total FG%")
                    Text("1 PT%")
                    Text("2 PT%")
                    Text("3 PT%")
                    Text("4 PT%")
                    // TODO: Conditionally show
                    Text("OT PTS")
                    Text("OT FG%")
                }.font(.title)
            }.padding([.leading, .trailing]).font(.title).lineLimit(1)

            if isTournament {
                Button("Back to Games", action: {
                    NavigationUtil.popToViewByTitle(viewTitle: game.tournament?.name ?? "")
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

struct GameStatsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let games =
        TourneyHelper.fetchDataFromContext(viewContext, nil, "Game", []) as! [Game]
        let game = games[0]

        return NavigationView {
            GameStatsView(team1: "KU", team2: "DUKE", team1Score: 80, team2Score: 76, game: game).environment(\.managedObjectContext, PreviewDataController.shared.container.viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
