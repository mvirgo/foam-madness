//
//  GameStatsView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct GameStatsView: View {
    @State var game: Game
    @State private var hasOvertimeStats = false
    @State private var statsArrays: [[String]] = [[], []]
    
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                labels
                Spacer()
                getStatsText(teamIndex: 0)
                Spacer()
                getStatsText(teamIndex: 1)
            }.padding([.leading, .trailing]).font(.title).lineLimit(1)

            if let _ = game.tournament {
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
        .onAppear {
            getStats()
        }
    }
    
    var labels: some View {
        VStack(alignment: .leading) {
            Text("X").font(.largeTitle).opacity(0)
            Text("Hand")
            Text("Points")
            Text("Total FG%")
            Text("1 PT%")
            Text("2 PT%")
            Text("3 PT%")
            Text("4 PT%")
            if hasOvertimeStats {
                Text("OT PTS")
                Text("OT FG%")
            }
        }.font(.title)
    }
    
    private func getStatsText(teamIndex: Int) -> some View {
        return VStack {
            ForEach(0..<statsArrays[teamIndex].count, id: \.self) { i in
                if i == 0 {
                    Text(String(statsArrays[teamIndex][i])).font(.largeTitle)
                } else {
                    Text(String(statsArrays[teamIndex][i]))
                }
            }
        }.font(.title)
    }
    
    private func getStats() {
        let stats = GameStatsController().loadStats(game)
        statsArrays[0] = stats.team1Stats
        statsArrays[1] = stats.team2Stats
        hasOvertimeStats = stats.hasOvertimeStats
    }
}

struct GameStatsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let predicate = NSPredicate(format: "completion == YES")
        let games = TourneyHelper.fetchDataFromContext(viewContext, predicate, "Game", []) as! [Game]

        return NavigationView {
            GameStatsView(game: games[0]).environment(\.managedObjectContext, PreviewDataController.shared.container.viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
