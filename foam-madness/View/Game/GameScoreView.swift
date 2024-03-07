//
//  GameScoreView.swift
//  foam-madness
//
//  Created by Michael Virgo on 1/16/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI

struct GameScoreView: View {
    @State var game: Game
    @State private var gameScoreHeader = "Final Score"
    @State private var team1Name = ""
    @State private var team2Name = ""
    @State private var team1Score = "0"
    @State private var team2Score = "0"

    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Text(gameScoreHeader).font(.title).fontWeight(.bold)
                HStack {
                    Text(team1Name)
                        .font(.largeTitle)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    Text(team1Score).font(.largeTitle)
                }
                HStack {
                    Text(team2Name)
                        .font(.largeTitle)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    Text(team2Score).font(.largeTitle)
                }
            }.padding([.leading, .trailing])
            
            if !game.isSimulated {
                // Hide stats if simulated - no stats to show
                NavigationLink(destination: GameStatsView(game: game)) {
                    Text("See Stats")
                }.buttonStyle(PrimaryButtonFullWidthStyle()).padding()
            }
            
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
            setGameScoreDisplay()
        }
        .navigationBarBackButtonHidden()
    }
    
    func setGameScoreDisplay() {
        let teams = GameHelper.getOrderedTeams(game)
        // Show seed depending on if game is in a tourney
        if let _ = game.tournament {
            team1Name = String(game.team1Seed) + " - " + teams[0].name!
            team2Name = String(game.team2Seed) + " - " + teams[1].name!
        } else {
            team1Name = teams[0].name!
            team2Name = teams[1].name!
        }
        // Show scores
        team1Score = String(game.team1Score)
        team2Score = String(game.team2Score)
        // Add OT or Sim to header, if applicable
        if game.team1OTTaken > 0 {
            gameScoreHeader = "Final Score - OT"
        } else if game.isSimulated {
            gameScoreHeader = "Final Score - Sim"
        } else {
            gameScoreHeader = "Final Score"
        }
    }
}

struct GameScoreView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PreviewDataController.shared.container.viewContext
        let games = TourneyHelper.fetchDataFromContext(viewContext, nil, "Game", []) as! [Game]
        return NavigationView {
            GameScoreView(game: games[0]).environment(\.managedObjectContext, PreviewDataController.shared.container.viewContext)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
