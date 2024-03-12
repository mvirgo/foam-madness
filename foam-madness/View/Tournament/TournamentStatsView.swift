//
//  TournamentStatsView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI
import MessageUI

let titleText = ["Total", "Left Hand", "Right Hand"]

struct TournamentStatsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var tournament: Tournament
    @State private var statsArrays: [[Int]] = {
        let statArray = [Int](repeating: 0, count: 11)
        return [statArray, statArray, statArray]
    }()
    @State private var hasOvertimeStats = false
    @State private var selectedHand = 0

    var body: some View {
        VStack(spacing: 30) {
            Text("\(titleText[selectedHand]) Stats")
                .font(.largeTitle)

            HStack {
                labels
                Spacer()
                stats
            }
            .padding([.leading, .trailing], 20)
            .font(.title2)

            Picker("", selection: $selectedHand) {
                Text("Total").tag(0)
                Text("Left").tag(1)
                Text("Right").tag(2)
            }
            .pickerStyle(.segmented)
        }
        .padding([.leading, .trailing], 50)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Export", action: exportTournament)
            }
        }
        .onAppear {
            getStats()
        }
    }
    
    var labels: some View {
        VStack(alignment: .leading) {
            if (selectedHand == 0) {
                Text("Games")
                Text("Upsets")
            } else {
                let hand = selectedHand == 1 ? "L" : "R"
                let oppHand = selectedHand == 1 ? "R" : "L"
                Text("Games vs \(oppHand)")
                Text("Upsets vs \(oppHand)")
                Text("Win % vs \(oppHand)")
                Text("Games vs \(hand)")
            }
            Text("Pts per Game")
            Text("Total FG%")
            Text("1 ptr FG%")
            Text("2 ptr FG%")
            Text("3 ptr FG%")
            Text("4 ptr FG%")
            if hasOvertimeStats {
                Text("OT FG%")
            }
        }
    }
    
    var stats: some View {
        VStack(alignment: .trailing) {
            // Set all stats labels
            ForEach(0..<statsArrays[selectedHand].count - 1, id: \.self) { i in
                // Skip the win% and games vs for opp hand if All Hands selected
                if selectedHand != 0 || (i != 2 && i != 3) {
                    Text(String(statsArrays[selectedHand][i]))
                }
            }
            if hasOvertimeStats {
                Text(String(statsArrays[selectedHand][10]))
            }
        }
    }
    
    private func getStats() {
        let tournamentStatsController = TournamentStatsController(context: viewContext)
        let games = tournamentStatsController.getCompletedGames(tournament)
        if (games.count > 0) {
            let stats = tournamentStatsController.calculateAllStats(games)
            statsArrays = [
                stats.totalStatsArray,
                stats.leftStatsArray,
                stats.rightStatsArray,
            ]
            hasOvertimeStats = stats.hasOvertimeStats
        }
    }
    
    private func exportTournament() {
        // Export all games in the tournament to JSON
        var exportGames = [String: [String: String]]()
        for game in tournament.games! {
            let singleGame = GameHelper.createGameExportData(game as! Game)
            let key = singleGame.keys.first!
            exportGames[key] = singleGame[key]
        }
        MailHandler.shared.sendTournamentStatsEmail(
            tournamentName: tournament.name ?? "",
            exportGames: exportGames
        )
    }
}

struct TournamentStatsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let tournaments = TourneyHelper.fetchDataFromContext(viewContext, nil, "Tournament", []) as! [Tournament]

        NavigationView {
            TournamentStatsView(tournament: tournaments[0]).environment(\.managedObjectContext, viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
